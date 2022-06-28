//
//  CameraCapture.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices

class CameraCapture: NSObject {
    
    enum RecordingStatus: Int {
        case idle = 0
        case startingRecording
        case recording
        case stopingRecording
    }
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    var photoQuality: CGFloat = 1.0
    
    var cameraMaxZoom: CGFloat = 10.0
    
    var cameraZoom: CGFloat {
        get {
            return videoInput?.device.videoZoomFactor ?? 1.0
        } set {
            sessionQueue.async {
                guard let videoDevice = self.videoInput?.device else { return }
                do {
                    try videoDevice.lockForConfiguration()
                    videoDevice.videoZoomFactor = newValue
                    videoDevice.unlockForConfiguration()
                    self.delegate?.cameraCapture(self, didSetZoom: nil)
                } catch {
                    self.delegate?.cameraCapture(self, didSetZoom: .cannotLockConfiguration)
                }
            }
        }
    }
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    private let videoDeviceDiscoverySession: AVCaptureDevice.DiscoverySession
    
    private let session = AVCaptureSession()
    
    public private(set) var isSessionRunning = false
 
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    
    private let sessionQueue = DispatchQueue(label: "com.evokerdev.capture.sessionQueue",
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
    private let processingQueue = DispatchQueue(label: "com.evokerdev.capture.processingQueue",
                                                attributes: [],
                                                autoreleaseFrequency: .workItem)
    
    private let movieFileOutput = AVCaptureMovieFileOutput()
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private lazy var metadataOutput = AVCaptureMetadataOutput()
    
    private var sessionRunningContext = 0
    var videoOutputCompressed: Bool = false
    
    weak var delegate: CameraCaptureDelegate?
    
    var options: CameraEngine.Options
    
    init(options: CameraEngine.Options, delegate: CameraCaptureDelegate) {
        self.options = options
        
        var deviceTypes: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 13.0, *) {
            deviceTypes.append(.builtInTripleCamera)
        }
        deviceTypes.append(.builtInDualCamera)
        deviceTypes.append(.builtInWideAngleCamera)
        
        videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                       mediaType: .video,
                                                                       position: .unspecified)
        super.init()
        
        self.delegate = delegate
        
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    func startRunning() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                self.setTorchMode(true)
            default:
                break
            }
        }
    }
        
    func stopRunning() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
                self.setTorchMode(false)
            }
        }
    }
}

extension CameraCapture {
    
    func configureSession() {
        if setupResult != .success {
            return
        }
        
        guard PrivacyPermission.camera == .authorized else {
            setupResult = .notAuthorized
            return
        }
        
        let canAddAudioDevice = PrivacyPermission.microphone == .authorized
        
        guard let videoDevice = videoDeviceDiscoverySession.devices.first(where: { $0.position == options.devicePosition.toNatively() }) else {
            setupResult = .configurationFailed
            return
        }
        
        if canAddAudioDevice {
            guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
                setupResult = .configurationFailed
                return
            }
            
            do {
                audioInput = try AVCaptureDeviceInput(device: audioDevice)
            } catch {
                setupResult = .configurationFailed
                return
            }
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = options.resolution.toNatively()
        
        // Add a video input.
        guard session.canAddInput(videoInput!) else {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        cameraMaxZoom = videoInput!.device.activeFormat.videoMaxZoomFactor
        
        session.addInput(videoInput!)
        
        if canAddAudioDevice {
            guard session.canAddInput(audioInput!) else {
                print("Could not add audio device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
            session.addInput(audioInput!)
            
            //  Add video output
            if session.canAddOutput(movieFileOutput) {
                session.addOutput(movieFileOutput)

                movieFileOutput.movieFragmentInterval = .invalid
            } else {
                print("Could not add movie file output to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
        } else {
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add metadata output
        if options.mode == .scanCode {
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                if metadataOutput.availableMetadataObjectTypes.contains(.qr) {
                    metadataOutput.setMetadataObjectsDelegate(self, queue: processingQueue)
                    var metadataObjectTypes: [AVMetadataObject.ObjectType] = []
                    if options.scanType.contains(.qrCode) {
                        metadataObjectTypes.append(.qr)
                    }
                    if options.scanType.contains(.barCode) {
                        metadataObjectTypes.append(contentsOf: [.aztec, .code39, .code93,
                                                                .code128, .ean8, .ean13,
                                                                .itf14, .upce])
                    }
                    if options.scanType.contains(.pdf417) {
                        metadataObjectTypes.append(.pdf417)
                    }
                    if options.scanType.contains(.datamatrix) {
                        metadataObjectTypes.append(.dataMatrix)
                    }
                    metadataOutput.metadataObjectTypes = metadataObjectTypes
                }
            } else {
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        }
        
        captureFrameRate(videoDevice: videoDevice)
        
        session.commitConfiguration()
        
        delegate?.cameraCapture(self, didCompleteInit: cameraMaxZoom)
    }
    
    func configureVideoCapture() {
        guard PrivacyPermission.microphone == .authorized else { return }
        
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            setupResult = .configurationFailed
            return
        }
        
        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()
        
        guard session.canAddInput(audioInput!) else {
            print("Could not add audio device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.addInput(audioInput!)
        
        //  Add video output
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)

            movieFileOutput.movieFragmentInterval = .invalid
        } else {
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    private func captureFrameRate(videoDevice: AVCaptureDevice) {
        if let frameDuration = videoDevice.activeFormat.videoSupportedFrameRateRanges.first {
            do {
                try videoDevice.lockForConfiguration()
                videoDevice.activeVideoMinFrameDuration = frameDuration.minFrameDuration
                videoDevice.activeVideoMaxFrameDuration = frameDuration.maxFrameDuration
                videoDevice.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    private func setTorchMode(_ on: Bool) {
        if videoInput!.device.hasTorch {
            do {
                try videoInput!.device.lockForConfiguration()
                videoInput!.device.torchMode = on && self.options.flashMode == .torch ? .on : .off
                videoInput!.device.unlockForConfiguration()
            } catch {
                Logger.debug("cannot lock AVCaptureDevice for configuration")
            }
        }
    }
    
    private func addObservers() {
        removeObservers()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError(notification:)),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoInput?.device)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CameraCapture {
    
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
}

extension CameraCapture {
    
    func startRecording() {
        switch PrivacyPermission.microphone {
        case .authorized:
            guard isSessionRunning, let connection = movieFileOutput.connection(with: .video) else { return }
            connection.videoScaleAndCropFactor = 1
            let (_, filePath) = FilePath.generateTmpEVFilePath(ext: "mp4")
            movieFileOutput.startRecording(to: filePath, recordingDelegate: self)
        case .notDetermined:
            PrivacyPermission.requestMicrophone {
                self.sessionQueue.async {
                    self.configureVideoCapture()
                    self.startRecording()
                }
            }
        case .denied:
            break
        }
    }
    
    func stopRecording() {
        movieFileOutput.stopRecording()
    }
    
    func cancelRecording() {
        movieFileOutput.stopRecording()
    }
    
    func capturePhoto(quality: CGFloat = 1.0) {
        sessionQueue.async {
            self.photoQuality = quality
            let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
            if self.videoInput!.device.isFlashAvailable {
                switch self.options.flashMode {
                case .auto:
                    photoSettings.flashMode = .auto
                case .on:
                    photoSettings.flashMode = .on
                case .off,.torch:
                    photoSettings.flashMode = .off
                }
            }
            photoSettings.isAutoStillImageStabilizationEnabled = true
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

//MARK: Focus
extension CameraCapture {
    
    func focus(_ point: CGPoint) {
        let rect = CGRect.init(origin: point, size: .zero)
        let deviceRect = movieFileOutput.metadataOutputRectConverted(fromOutputRect: rect)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: deviceRect.origin, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        
        sessionQueue.async {
            guard let videoDevice = self.videoInput?.device else { return }
            
            do {
                try videoDevice.lockForConfiguration()
                if videoDevice.isFocusPointOfInterestSupported && videoDevice.isFocusModeSupported(focusMode) {
                    videoDevice.focusPointOfInterest = devicePoint
                    videoDevice.focusMode = focusMode
                }
                
                if videoDevice.isExposurePointOfInterestSupported && videoDevice.isExposureModeSupported(exposureMode) {
                    videoDevice.exposurePointOfInterest = devicePoint
                    videoDevice.exposureMode = exposureMode
                }
                
                videoDevice.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                videoDevice.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    @objc
    func subjectAreaDidChange(notification: Notification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus,
              exposureMode: .continuousAutoExposure,
              at: devicePoint,
              monitorSubjectAreaChange: false)
    }
    
    func turnCamera() {
        guard let currentPosition = videoInput?.device.position else { return }
        switch currentPosition {
        case .front, .unspecified:
            changeCameraDevicePosition(to: .back)
        case .back:
            changeCameraDevicePosition(to:.front)
        @unknown default:
            break
        }
    }
    
    func changeCameraDevicePosition(to position: CameraEngine.DevicePosition) {
        sessionQueue.async {
            guard let currentVideoDevice = self.videoInput?.device else { return }
            if currentVideoDevice.position == position.toNatively() {
                return
            }
                       
            let devices = self.videoDeviceDiscoverySession.devices
            if let videoDevice = devices.first(where: { $0.position == position.toNatively() }) {
                var videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    return
                }
                self.session.beginConfiguration()
                
                self.session.removeInput(self.videoInput!)
                
                if self.session.canAddInput(videoInput) {
                    NotificationCenter.default.removeObserver(self,
                                                              name: .AVCaptureDeviceSubjectAreaDidChange,
                                                              object: currentVideoDevice)
                    NotificationCenter.default.addObserver(self,
                                                           selector: #selector(self.subjectAreaDidChange),
                                                           name: .AVCaptureDeviceSubjectAreaDidChange,
                                                           object: videoDevice)
                    
                    self.session.addInput(videoInput)
                    self.videoInput = videoInput
                } else {
                    self.session.addInput(self.videoInput!)
                }
                
                self.session.commitConfiguration()
                
                self.setTorchMode(true)
            }
        }
    }
    
}

//MARK: AVCaptureMetadataOutputObjectsDelegate
extension CameraCapture: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty else {
            return
        }
        
        if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
           let value = object.stringValue {
            self.delegate?.cameraCapture(self, didScanCode: value, type: object.type)
        }
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension CameraCapture: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.delegate?.cameraCapture(didStartRecord: self, error: nil)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            self.delegate?.cameraCapture(self, didFinishRecord: .recordFail(error.localizedDescription))
            return
        }
        
        processingQueue.async {
            let (videoEVFile, videoFilePath) = FilePath.generateTmpEVFilePath(ext: "mp4")
            VideoUtil.cropVideo(url: outputFileURL,
                                destURL: videoFilePath,
                                compressed: self.videoOutputCompressed,
                                size: self.previewLayer.frame.size) {
                try? FileManager.default.removeItem(at: outputFileURL)
                let posterData = VideoUtil.videoPosterImage(url: videoFilePath)?.jpegData(compressionQuality: 0.8)
                let (posterEVFile, posterFilePath) = FilePath.generateTmpEVFilePath(ext: "jpg")
                FileManager.default.createFile(atPath: posterFilePath.path, contents: posterData, attributes: nil)
                self.delegate?.cameraCapture(self, didFinishRecord: videoEVFile, posterFilePath: posterEVFile)
            }
        }
    }
}

// MARK: AVCapturePhotoCaptureDelegate
extension CameraCapture: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoPixelBuffer = photo.pixelBuffer else {
            delegate?.cameraCapture(self, didFinishTakePhoto: .missingPixelBuffer(error?.localizedDescription ?? ""))
            return
        }
        
        var photoFormatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: photoPixelBuffer,
                                                     formatDescriptionOut: &photoFormatDescription)
        
        processingQueue.async {
            let metadataAttachments: CFDictionary = photo.metadata as CFDictionary
            guard var data = VideoUtil.data(with: photoPixelBuffer,
                                            attachments: metadataAttachments,
                                            imageType: kUTTypeJPEG),
                  var image = UIImage(data: data) else {
                self.delegate?.cameraCapture(self, didFinishTakePhoto: .pixelBufferToDataFail)
                return
            }
            
            let width = image.size.width
            let rate = self.previewLayer.frame.height / self.previewLayer.frame.width
            let height = width * rate
            let targetRect = CGSize(width: width, height: height)
            image = image.sd_resizedImage(with: targetRect, scaleMode: .aspectFill) ?? image
            data = image.jpegData(compressionQuality: self.photoQuality) ?? data
            
            let (evfile, filePath) = FilePath.generateTmpEVFilePath(ext: "jpg")
            do {
                try FilePath.createDirectory(at: filePath.deletingLastPathComponent())
            } catch {
                self.delegate?.cameraCapture(self, didFinishTakePhoto: .generateEVFileFail)
                return
            }
            
            if FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil) {
                self.delegate?.cameraCapture(self, didFinishTakePhoto: evfile)
            } else {
                self.delegate?.cameraCapture(self, didFinishTakePhoto: .generateEVFileFail)
            }
        }
    }
    
}

protocol CameraCaptureDelegate: NSObjectProtocol {
    
    func cameraCapture(_ cameraCapture: CameraCapture, didCompleteInit maxZoom: CGFloat)
    
    // take photo
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishTakePhoto evfile: String)
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishTakePhoto error: CameraCaptureError)
    
    // record video
    func cameraCapture(didStartRecord cameraCapture: CameraCapture, error: CameraCaptureError?)
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishRecord videoFilePath: String, posterFilePath: String)
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishRecord error: CameraCaptureError)
    
    // scan code
    func cameraCapture(_ cameraCapture: CameraCapture, didScanCode code: String, type: AVMetadataObject.ObjectType)
    
    func cameraCapture(_ cameraCapture: CameraCapture, didSetZoom error: CameraCaptureError?)
}

public enum CameraCaptureError: Error {
    
    case sessionNotRunning
    
    case missingPixelBuffer(String)
    
    case pixelBufferToDataFail
    
    case generateEVFileFail
    
    case recordFail(String)
    
    case cannotLockConfiguration
}
