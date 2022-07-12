//
//  CameraEngine.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import Photos

public class CameraEngine: NSObject {
    
    private var capture: CameraCapture!
    
    public var options: Options {
        return capture.options
    }
    
    public var flashMode: FlashMode {
        get {
            return capture.options.flashMode
        } set {
            capture.options.flashMode = newValue
        }
    }
    
    public var zoom: CGFloat {
        return capture.cameraZoom
    }
    
    public var initDoneHandler: CGFloatBlock?
    
    public var errorHandler: StringBlock?
    
    public var scanCodeHandler: ((String, AVMetadataObject.ObjectType) -> Void)?
    
    private var takePhotoCompletionHandler: ((String?, CameraCaptureError?) -> Void)?
    
    private var recordCompletionHandler: ((String?, String?, CameraCaptureError?) -> Void)?
    
    private var startRecordCompletionHandler: ((CameraCaptureError?) -> Void)?
    
    private var setZoomCompletionHandler: ((CameraCaptureError?) -> Void)?
    
    private let previewView = UIView()
    
    private var initDone = false
    
    private var zoomFactor: CGFloat = 1.0
    
    private lazy var scanCodeThrottle = Throttler(seconds: 0.25)
    
    private var linearSetZoomTimer: Timer?
    
    public init(options: Options) {
        super.init()
        
        capture = CameraCapture(options: options, delegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        previewView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomPinch(_:)))
        previewView.addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(zoomDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        previewView.addGestureRecognizer(doubleTapGesture)
        
        tapGesture.require(toFail: doubleTapGesture)
    }
    
    deinit {
        invalidateTimer()
    }
    
    public func addPreviewTo(_ view: UIView) {
        if previewView.superview != nil {
            previewView.removeFromSuperview()
        }
        let layer = capture.previewLayer
        layer.frame = view.frame
        previewView.layer.insertSublayer(layer, at: 0)
        view.addSubview(previewView)
        previewView.autoPinEdgesToSuperviewEdges()
    }
    
    public func startRunning() {
        capture.startRunning()
    }
    
    public func stopRunning() {
        capture.stopRunning()
    }
    
    public func changeCameraDevicePosition(to position: DevicePosition) {
        capture.changeCameraDevicePosition(to: position)
    }
    
    public func turnCamera() {
        capture.turnCamera()
    }
    
    public func takePhoto(quality: CGFloat,
                          completionHandler handler: @escaping (String?, CameraCaptureError?) -> Void) {
        takePhotoCompletionHandler = nil
        guard capture.isSessionRunning else {
            handler(nil, .sessionNotRunning)
            return
        }
        takePhotoCompletionHandler = handler
        capture.capturePhoto(quality: quality)
    }
    
    public func startRecording(completionHandler handler: @escaping (CameraCaptureError?) -> Void) {
        startRecordCompletionHandler = handler
        capture.startRecording()
    }
    
    public func stopRecord(compressed: Bool,
                           completionHandler handler: @escaping (String?, String?, CameraCaptureError?) -> Void) {
        recordCompletionHandler = nil
        guard capture.isSessionRunning else {
            handler(nil, nil, .sessionNotRunning)
            return
        }
        recordCompletionHandler = handler
        capture.videoOutputCompressed = compressed
        capture.stopRecording()
    }
    
    public func setZoom(_ zoom: CGFloat, completionHandler handler: @escaping (CameraCaptureError?) -> Void) {
        setZoomCompletionHandler = handler
        let zoom = zoom.clampe(to: 1...capture.cameraMaxZoom)
        capture.cameraZoom = zoom
        zoomFactor = zoom
    }
    
    private func invalidateTimer() {
        linearSetZoomTimer?.invalidate()
        linearSetZoomTimer = nil
    }
}

//MARK: Gesture
extension CameraEngine {
    
    @objc func focusAndExposeTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: previewView)
        let point = capture.previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        capture.focus(point)
    }
    
    @objc func zoomDoubleTap(_ gesture: UITapGestureRecognizer) {
        invalidateTimer()
    
        let frames: TimeInterval = 1 / 60
        let duration: TimeInterval = 0.25
        let count = duration / frames
        if capture.cameraZoom >= 1.5 {
            let diff = capture.cameraZoom - 1
            let step = diff / count
            linearSetZoomTimer = Timer(timeInterval: frames, repeats: true, block: { [unowned self] _ in
                let zoom = (self.capture.cameraZoom - step).clampe(to: 1...self.capture.cameraMaxZoom)
                self.capture.cameraZoom = zoom
                if self.capture.cameraZoom <= 1 {
                    self.invalidateTimer()
                }
                self.zoomFactor = zoom
            })
            RunLoop.main.add(linearSetZoomTimer!, forMode: .common)
        } else if capture.cameraZoom < 1.5 {
            let diff = 2 - capture.cameraZoom
            let step = diff / count
            linearSetZoomTimer = Timer(timeInterval: frames, repeats: true, block: { [unowned self] _ in
                let zoom = (self.capture.cameraZoom + step).clampe(to: 1...self.capture.cameraMaxZoom)
                self.capture.cameraZoom = zoom
                if self.capture.cameraZoom >= 2 {
                    self.invalidateTimer()
                }
                self.zoomFactor = zoom
            })
            RunLoop.main.add(linearSetZoomTimer!, forMode: .common)
        }
        
    }
    
    @objc func zoomPinch(_ gesture: UIPinchGestureRecognizer) {
        let zoom = (gesture.scale * zoomFactor).clampe(to: 1...capture.cameraMaxZoom)
        switch gesture.state {
        case .began:
            fallthrough
        case .changed:
            capture.cameraZoom = zoom
        case .ended:
            zoomFactor = zoom
            capture.cameraZoom = zoomFactor
        default:
            break
        }
    }
}

//MARK: CameraCaptureDelegate
extension CameraEngine: CameraCaptureDelegate {
    
    func cameraCapture(_ cameraCapture: CameraCapture, didCompleteInit maxZoom: CGFloat) {
        if !initDone {
            initDone = true
            initDoneHandler?(maxZoom)
        }
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishTakePhoto ekfile: String) {
        takePhotoCompletionHandler?(ekfile, nil)
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishTakePhoto error: CameraCaptureError) {
        takePhotoCompletionHandler?(nil, error)
    }
    
    func cameraCapture(didStartRecord cameraCapture: CameraCapture, error: CameraCaptureError?) {
        startRecordCompletionHandler?(error)
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishRecord videoFilePath: String, posterFilePath: String) {
        recordCompletionHandler?(videoFilePath, posterFilePath, nil)
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didFinishRecord error: CameraCaptureError) {
        recordCompletionHandler?(nil, nil, error)
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didScanCode code: String, type: AVMetadataObject.ObjectType) {
        scanCodeThrottle.invoke { [unowned self] in
            self.scanCodeHandler?(code, type)
        }
    }
    
    func cameraCapture(_ cameraCapture: CameraCapture, didSetZoom error: CameraCaptureError?) {
        setZoomCompletionHandler?(error)
    }
}

extension CameraEngine {
    
    public struct Options {
        let mode: Mode
        let resolution: Resolution
        let devicePosition: DevicePosition
        var flashMode: FlashMode
        let scanType: [ScanType]
        
        enum Mode: String, Decodable {
            case normal
            case scanCode
        }
    }
    
    public enum DevicePosition: String, Codable {
        case back
        case front
        
        func toNatively() -> AVCaptureDevice.Position {
            switch self {
            case .back:
                return .back
            case .front:
                return .front
            }
        }
    }
    
    public enum FlashMode: String, Decodable {
        case auto
        case on
        case off
        case torch
    }
    
    public enum ScanType: String, Decodable {
        case barCode
        case qrCode
        case datamatrix
        case pdf417
    }
    
    public enum Resolution: String, Codable {
        case low
        case medium
        case high
        
        func toNatively() -> AVCaptureSession.Preset {
            switch self {
            case .low:
                return .low
            case .medium:
                return .medium
            case .high:
                return .high
            }
        }
    }
}

//MARK: SubscribeKey
extension CameraEngine {
    
    public static let onInitDoneSubscribeKey = SubscribeKey("MODULE_CAMERA_ON_INIT_DONE")
    
    public static let onErrorSubscribeKey = SubscribeKey("MODULE_CAMERA_ON_ERROR")
    
    public static let onScanCodeSubscribeKey = SubscribeKey("MODULE_CAMERA_ON_SCAN_CODE")
}

