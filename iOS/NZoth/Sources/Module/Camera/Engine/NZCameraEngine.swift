//
//  NZCameraEngine.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import Photos

public class NZCameraEngine: NSObject {
    
    private var capture: NZCapture!
    
    var capturePhotoCompleted: ((UIImage?, Data?, NZCaptureError?) -> Void)?
    
    var recordCompleted: ((String?, String?, NZCaptureError?) -> Void)?
    
    var initDoneHandler: NZCGFloatBlock?
    
    var errorHandler: NZStringBlock?
    
    var scanCodeHandler: ((String, AVMetadataObject.ObjectType) -> Void)?
    
    private let previewView = UIView()
    
    private var initDone = false
    private var actionLock = false
    private var zoomFactor: CGFloat = 1.0
    
    var zoom: CGFloat {
        get {
            return capture.cameraZoom
        } set {
            capture.cameraZoom = newValue
        }
    }
    
    lazy var scanCodeThrottle = Throttler(seconds: 0.25)
    
    init(options: NZCapture.Options) {
        super.init()
        capture = NZCapture(options: options, delegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap(_:)))
        previewView.addGestureRecognizer(tapGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomPinch(_:)))
        previewView.addGestureRecognizer(pinchGesture)
    }
    
    func addPreviewTo(_ view: UIView) {
        if previewView.superview != nil {
            previewView.removeFromSuperview()
        }
        let layer = capture.previewLayer
        layer.frame = view.frame
        previewView.layer.insertSublayer(layer, at: 0)
        view.addSubview(previewView)
        previewView.autoPinEdgesToSuperviewEdges()
    }
    
    func startRunning() {
        capture.startRunning()
    }
    
    func stopRunning() {
        capture.stopRunning()
    }
    
    func changeCamera(_ position: AVCaptureDevice.Position) {
        capture.changeCamera(position)
    }
    
    func turnCamera() {
        capture.turnCamera()
    }
    
    func capturePhoto(quality: CGFloat, flashMode: AVCaptureDevice.FlashMode, _ completed: @escaping ((UIImage?, Data?, NZCaptureError?) -> Void)) {
        guard capture.isSessionRunning else {
            actionLock = false
            completed(nil, nil, .sessionNotRunning)
            return
        }
        
        guard !actionLock else {
            completed(nil, nil, .eventLocking)
            return
        }
        
        actionLock = true
        capturePhotoCompleted = completed
        capture.capturePhoto(quality: quality, flashMode: flashMode)
        flashScreen()
    }
    
    func startRecording() {
        capture.startRecording()
    }
    
    func stopRecording(compressed: Bool, _ completed: @escaping ((String?, String?, NZCaptureError?) -> Void)) {
        recordCompleted = completed
        capture.videoOutputCompressed = compressed
        capture.stopRecording()
    }
    
    func cancelRecording() {
        capture.cancelRecording()
    }
    
    func flashScreen() {
        let flashView = UIView(frame: previewView.frame)
        previewView.addSubview(flashView)
        flashView.backgroundColor = .black
        flashView.layer.opacity = 1
        UIView.animate(withDuration: 0.25, animations: {
            flashView.layer.opacity = 0
        }, completion: { _ in
            flashView.removeFromSuperview()
        })
    }

}

//MARK: Gesture
extension NZCameraEngine {
    
    @objc func focusAndExposeTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: previewView)
        let point = capture.previewLayer.captureDevicePointConverted(fromLayerPoint: location)
        capture.focus(point)
    }
    
    @objc func zoomDoubleTap(_ gesture: UITapGestureRecognizer) {
        capture.cameraZoom = 2
    }
    
    @objc func zoomPinch(_ gesture: UIPinchGestureRecognizer) {
        let newScaleFactor = minMax(gesture.scale * zoomFactor, minimum: 1.0, maximum: capture.cameraMaxZoom)
        switch gesture.state {
        case .began:
            fallthrough
        case .changed:
            capture.cameraZoom = newScaleFactor
        case .ended:
            zoomFactor = newScaleFactor
            capture.cameraZoom = zoomFactor
        default:
            break
        }
    }
}

//MARK: NZCaptureDelegate
extension NZCameraEngine: NZCaptureDelegate {
   
    func capture(didStartRunning capture: NZCapture) {
        if !initDone {
            initDone = true
            initDoneHandler?(capture.cameraMaxZoom)
        }
    }
    
    func capture(_ capture: NZCapture, didStopRunning error: NZCaptureError?) {
        
    }
    
    func capture(didStartRecord capture: NZCapture) {
        
    }
    
    func capture(_ capture: NZCapture, redordDidFinish error: NZCaptureError) {
        
    }
    
    func capture(_ capture: NZCapture, didStopRecording videoFilePath: String?, posterFilePath: String?) {
        DispatchQueue.main.async {
            self.recordCompleted?(videoFilePath, posterFilePath, nil)
        }
    }
    
    func capture(_ capture: NZCapture, changedDevide position: AVCaptureDevice.Position) {
       
    }
    
    func capture(_ capture: NZCapture, didCapture photo: (UIImage?, Data?), error: NZCaptureError?) {
        DispatchQueue.main.async {
            self.capturePhotoCompleted?(photo.0, photo.1, error)
            self.actionLock = false
        }
    }
    
    func capture(_ capture: NZCapture, didScanCode code: String, type: AVMetadataObject.ObjectType) {
        scanCodeThrottle.invoke { [unowned self] in
            DispatchQueue.main.async {
                self.scanCodeHandler?(code, type)
            }
        }
    }
    
}

//MARK: NZSubscribeKey
extension NZCameraEngine {
    
    public static let onInitDoneSubscribeKey = NZSubscribeKey("MODULE_CAMERA_ON_INIT_DONE")
    
    public static let onErrorSubscribeKey = NZSubscribeKey("MODULE_CAMERA_ON_ERROR")
    
    public static let onScanCodeSubscribeKey = NZSubscribeKey("MODULE_CAMERA_ON_SCAN_CODE")
}
