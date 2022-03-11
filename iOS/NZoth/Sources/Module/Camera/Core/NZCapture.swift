//
//  NZCapture.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import UIKit
import AVFoundation
import Photos

enum NZCaptureError {
    
    case permissionDenied
    
    case eventLocking
    
    case sessionNotRunning
    
    case fail
}

protocol NZCaptureDelegate: NSObjectProtocol {
    
    func capture(didStartRunning capture: NZCapture)
    
    func capture(_ capture: NZCapture, didStopRunning error: NZCaptureError?)
    
    func capture(_ capture: NZCapture, changedDevide position: AVCaptureDevice.Position)
        
    // take photo
    func capture(_ capture: NZCapture, didCapture photo: (UIImage?, Data?), error: NZCaptureError?)
    
    // record video
    func capture(didStartRecord capture: NZCapture)
    
    func capture(_ capture: NZCapture, redordDidFinish error: NZCaptureError)
    
    func capture(_ capture: NZCapture, didStopRecording videoFilePath: String?, posterFilePath: String?)
    
    // scan code
    func capture(_ capture: NZCapture, didScanCode code: String, type: AVMetadataObject.ObjectType)
}

class NZCapture: NSObject {
    
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
    
    var cameraZoom: CGFloat = 1.0 {
        willSet {
            sessionQueue.async {
                guard let videoDevice = self.videoInput?.device else { return }
                do {
                    try videoDevice.lockForConfiguration()
                    videoDevice.videoZoomFactor = newValue
                    videoDevice.unlockForConfiguration()
                } catch {
                    print("Could not lock device for configuration: \(error)")
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
    
    private let sessionQueue = DispatchQueue(label: "com.nozthdev.capture.sessionQueue",
                                             attributes: [],
                                             autoreleaseFrequency: .workItem)
    private let processingQueue = DispatchQueue(label: "com.nozthdev.capture.processingQueue",
                                                attributes: [],
                                                autoreleaseFrequency: .workItem)
    
    private let movieFileOutput = AVCaptureMovieFileOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private lazy var metadataOutput = AVCaptureMetadataOutput()
    
    private var sessionRunningContext = 0
    var videoOutputCompressed: Bool = false
    
    weak var delegate: NZCaptureDelegate?
    
    struct Options {
        let mode: Mode
        let resolution: AVCaptureSession.Preset
        let position: AVCaptureDevice.Position
        let scanType: [ScanType]
    }
    
    enum Mode: String, Codable {
        case normal
        case scanCode
    }
    
    enum ScanType: String, Decodable {
        case barCode
        case qrCode
        case datamatrix
        case pdf417
    }
    
    private let options: Options
    init(options: Options, delegate: NZCaptureDelegate) {
        self.options = options
        
        var deviceTypes: [AVCaptureDevice.DeviceType] = []
        if #available(iOS 13.0, *) {
            deviceTypes.append(.builtInTripleCamera)
        }
        deviceTypes.append(.builtInDualCamera)
        deviceTypes.append(.builtInWideAngleCamera)
        
        videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: deviceTypes,
                                                                       mediaType: .video,
                                                                       position: options.position)
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
                DispatchQueue.main.async {
                    self.delegate?.capture(didStartRunning: self)
                }
            case .notAuthorized:
                DispatchQueue.main.async {
                    print("notAuthorized")
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    print("configurationFailed")
                }
            }
        }
    }
        
    func stopRunning() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
                self.delegate?.capture(self, didStopRunning: nil)
            }
        }
    }
}

extension NZCapture {
    
    func configureSession() {
        if setupResult != .success {
            return
        }
        
        guard PrivacyPermission.camera == .authorized else {
            setupResult = .notAuthorized
            return
        }
        
        let canAddAudioDevice = PrivacyPermission.microphone == .authorized
        
        guard let videoDevice = videoDeviceDiscoverySession.devices.first else {
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
        
        session.sessionPreset = options.resolution
        
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
        
        capFrameRate(videoDevice: videoDevice)
        
        session.commitConfiguration()
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
    
    private func capFrameRate(videoDevice: AVCaptureDevice) {
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
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoInput?.device)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension NZCapture {
    
    @objc func didEnterBackground(notification: NSNotification) {

    }
    
    @objc func willEnterForground(notification: NSNotification) {

    }
        
    @objc func sessionRuntimeError(notification: NSNotification) {
        guard let errorValue = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        let error = AVError(_nsError: errorValue)
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.capture(self, didStopRunning: .fail)
                    }
                }
            }
        } else {
            self.delegate?.capture(self, didStopRunning: .fail)
        }
    }
    
}

extension NZCapture {
    
    func startRecording() {
        switch PrivacyPermission.microphone {
        case .authorized:
            guard isSessionRunning, let connection = movieFileOutput.connection(with: .video) else { return }
            connection.videoScaleAndCropFactor = 1
            let (filePath, _) = FilePath.createTempNZFilePath(ext: "mp4")
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
    
    func capturePhoto(quality: CGFloat = 1.0, flashMode: AVCaptureDevice.FlashMode = .off) {
        sessionQueue.async {
            self.photoQuality = quality
            let photoSettings = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)])
            photoSettings.flashMode = flashMode
            photoSettings.isAutoStillImageStabilizationEnabled = true
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

//MARK: Focus
extension NZCapture {
    
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
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    func turnCamera() {
        guard let currentPosition = videoInput?.device.position else { return }
        switch currentPosition {
        case .front, .unspecified:
            changeCamera(.back)
        case .back:
            changeCamera(.front)
        @unknown default:
            break
        }
    }
    
    func changeCamera(_ position: AVCaptureDevice.Position) {
        sessionQueue.async {
            guard let currentVideoDevice = self.videoInput?.device else { return }
            if currentVideoDevice.position == position {
                return
            }
            
            let preferredPosition = position
           
            let devices = self.videoDeviceDiscoverySession.devices
            if let videoDevice = devices.first(where: { $0.position == preferredPosition }) {
                var videoInput: AVCaptureDeviceInput
                do {
                    videoInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    print("Could not create video device input: \(error)")
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
                    print("Could not add video device input to the session")
                    self.session.addInput(self.videoInput!)
                }
                
                if let unwrappedPhotoOutputConnection = self.photoOutput.connection(with: .video) {
                    let connection = self.photoOutput.connection(with: .video)!
                    connection.videoOrientation = unwrappedPhotoOutputConnection.videoOrientation
                    connection.isVideoMirrored = self.videoInput!.device.position == .front
                }
                
                self.session.commitConfiguration()
            }
            
            let videoPosition = self.videoInput!.device.position
            self.delegate?.capture(self, changedDevide: videoPosition)
        }
    }
    
}

//MARK: AVCaptureMetadataOutputObjectsDelegate
extension NZCapture: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty else {
            return
        }
        
        if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
           let value = object.stringValue {
            DispatchQueue.main.async {
                self.delegate?.capture(self, didScanCode: value, type: object.type)
            }
        }
    }
}

// MARK: AVCaptureFileOutputRecordingDelegate
extension NZCapture: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.delegate?.capture(didStartRecord: self)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            print(error!)
            return
        }
        
        processingQueue.async {
            let dest = FilePath.createTempNZFilePath(ext: "mp4")
            VideoUtil.cropVideo(url: outputFileURL,
                                destURL: dest.0,
                                compressed: self.videoOutputCompressed,
                                size: self.previewLayer.frame.size) {
                try? FileManager.default.removeItem(at: outputFileURL)
                let thumbData = VideoUtil.videoPosterImage(url: dest.0)?.jpegData(compressionQuality: 1.0)
                let thumbDest = FilePath.createTempNZFilePath(ext: "jpg")
                FileManager.default.createFile(atPath: thumbDest.0.path, contents: thumbData, attributes: nil)
                DispatchQueue.main.async {
                    self.delegate?.capture(self, didStopRecording: dest.1, posterFilePath: thumbDest.1)
                }
            }
        }
    }
}

// MARK: AVCapturePhotoCaptureDelegate
extension NZCapture: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {

    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoPixelBuffer = photo.pixelBuffer else {
            print("Error occurred while capturing photo: Missing pixel buffer (\(String(describing: error)))")
            DispatchQueue.main.async {
                self.delegate?.capture(self, didCapture: (nil, nil), error: .fail)
            }
            return
        }
        
        var photoFormatDescription: CMFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                     imageBuffer: photoPixelBuffer,
                                                     formatDescriptionOut: &photoFormatDescription)
        
        processingQueue.async {
            let metadataAttachments: CFDictionary = photo.metadata as CFDictionary
            guard var jpegData = VideoUtil.jpegData(with: photoPixelBuffer, attachments: metadataAttachments) else {
                print("Unable to create JPEG photo")
                DispatchQueue.main.async {
                    self.delegate?.capture(self, didCapture: (nil, nil), error: .fail)
                }
                return
            }
            
            guard var image = UIImage(data: jpegData) else {
                print("Unable to create JPEG photo")
                DispatchQueue.main.async {
                    self.delegate?.capture(self, didCapture: (nil, nil), error: .fail)
                }
                return
            }
            
            let width = image.size.width
            let rate = self.previewLayer.frame.height / self.previewLayer.frame.width
            let height = width * rate
            let targetRect = CGSize(width: width, height: height)
            image = image.sd_resizedImage(with: targetRect, scaleMode: .aspectFill) ?? image
            jpegData = image.jpegData(compressionQuality: self.photoQuality) ?? jpegData
            
            self.delegate?.capture(self, didCapture: (image, jpegData), error: nil)
        }
    }
    
}
