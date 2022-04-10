//
//  NZCameraAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation

enum NZCameraAPI: String, NZBuiltInAPI {
    
    case insertCamera
    case operateCamera
    case openNativelyCamera
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .insertCamera:
                insertCamera(args: args, bridge: bridge)
            case .operateCamera:
                operateCamera(args: args, bridge: bridge)
            case .openNativelyCamera:
                openNativelyCamera(args: args, bridge: bridge)
            }
        }
    }
    
    private func insertCamera(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable  {
            let parentId: String
            let cameraId: Int
            let mode: NZCapture.Mode
            let devicePosition: DevicePosition
            let resolution: Resolution
            let flash: Flash
        }
        
        enum Flash: String, Decodable {
            case auto
            case on
            case off
            case torch
        }
        
        enum DevicePosition: String, Codable {
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
        
        enum Resolution: String, Codable {
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
        
        guard let appService = bridge.appService else { return }

        guard let webView = bridge.container as? NZWebView, let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let cameraModule: NZCameraModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let setup = {
            let options = NZCapture.Options(mode: params.mode,
                                                    resolution: params.resolution.toNatively(),
                                                    position: params.devicePosition.toNatively(),
                                                    scanType: [.barCode, .qrCode])
            let cameraEngine = NZCameraEngine(options: options)
            cameraEngine.initDoneHandler = { maxZoom in
                let data: [String: Any] = ["cameraId": params.cameraId, "maxZoom": maxZoom]
                bridge.subscribeHandler(method: NZCameraEngine.onInitDoneSubscribeKey, data: data)
            }
            cameraEngine.errorHandler = { error in
                let data: [String: Any] = ["cameraId": params.cameraId, "error": error]
                bridge.subscribeHandler(method: NZCameraEngine.onErrorSubscribeKey, data: data)
            }
            cameraEngine.scanCodeHandler = { value, _ in
                let data: [String: Any] = ["cameraId": params.cameraId, "value": value]
                bridge.subscribeHandler(method: NZCameraEngine.onScanCodeSubscribeKey, data: data)
            }
            cameraEngine.startRunning()
            cameraEngine.addPreviewTo(container)
            cameraModule.cameras[page.pageId] = cameraEngine
            bridge.invokeCallbackSuccess(args: args)
        }
        
        let denied = {
            let error = NZError.bridgeFailed(reason: .custom("insertCamera: fail auth deny"))
            bridge.subscribeHandler(method: NZCameraEngine.onErrorSubscribeKey,
                                    data: ["cameraId": params.cameraId, "error": error.localizedDescription])
        }
        
        switch PrivacyPermission.camera {
        case .authorized:
            setup()
        case .notDetermined:
            PrivacyPermission.requestCamera {
                if PrivacyPermission.camera == .authorized {
                    setup()
                } else {
                    denied()
                }
            }
        case .denied:
            denied()
        }
    }
    
    private func operateCamera(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let cameraId: Int
            let method: Method
            let data: [String: Any]
            
            enum CodingKeys: String, CodingKey {
                case cameraId, method, data
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                cameraId = try container.decode(Int.self, forKey: .cameraId)
                method = try container.decode(Method.self, forKey: .method)
                data = try container.decode([String: Any].self, forKey: .data)
            }
        }
        
        enum Method: String, Decodable {
            case takePhoto
            case startRecord
            case stopRecord
            case setZoom
        }
        
        guard let appService = bridge.appService else { return }

        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.currentPage as? NZWebPage else {
            let error = NZError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let cameraModule: NZCameraModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let cameraEngine = cameraModule.cameras[page.pageId] else {
            let error = NZError.bridgeFailed(reason: .cameraNotFound(params.cameraId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .takePhoto:
            let quality: CGFloat
            switch params.data["quality"] as? String {
            case "high":
                quality = 1.0
            case "normal":
                quality = 0.7
            case "low":
                quality = 0.3
            default:
                quality = 0.7
            }
            cameraEngine.capturePhoto(quality: quality, flashMode: .off) { image, data, error in
                if error != nil {
                    bridge.invokeCallbackFail(args: args, error: .custom("take photo fail"))
                } else if let data = data {
                    let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: "jpg")
                    do {
                        try FilePath.createDirectory(at: filePath.deletingLastPathComponent())
                    } catch {
                        bridge.invokeCallbackFail(args: args, error: .custom("take photo save data fail"))
                        return
                    }
                    if FileManager.default.createFile(atPath: filePath.path, contents: data, attributes: nil) {
                        bridge.invokeCallbackSuccess(args: args, result: ["tempImagePath": nzfile])
                    } else {
                        bridge.invokeCallbackFail(args: args, error: .custom("take photo save data fail"))
                    }
                } else {
                    bridge.invokeCallbackFail(args: args, error: .custom("take photo fail"))
                }
            }
        case .startRecord:
            cameraEngine.startRecording()
            bridge.invokeCallbackSuccess(args: args)
        case .stopRecord:
            let compressed = params.data["compressed"] as? Bool ?? false
            cameraEngine.stopRecording(compressed: compressed) { videoPath, thumbPath, error in
                if error != nil {
                    bridge.invokeCallbackFail(args: args, error: .custom("video record fail"))
                } else if let videoPath = videoPath, let thumbPath = thumbPath {
                    bridge.invokeCallbackSuccess(args: args,
                                                 result: ["tempThumbPath": thumbPath, "tempVideoPath": videoPath])
                } else {
                    bridge.invokeCallbackFail(args: args, error: .custom("video record fail"))
                }
            }
        case .setZoom:
            if let zoom = params.data["zoom"] {
                if let value = zoom as? Int {
                    cameraEngine.zoom = CGFloat(value)
                } else if let value = zoom as? CGFloat {
                    cameraEngine.zoom = value
                }
            }
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func openNativelyCamera(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let type: MediaType
            let sizeType: [SizeType]
            var maxDuration: TimeInterval?
            var cameraDevice: CameraDevice?
            
            enum MediaType: String, Decodable {
                case photo
                case video
            }
            
            enum SizeType: String, Decodable {
                case original
                case compressed
            }
            
            enum CameraDevice: String, Decodable {
                case back
                case front
                
                func toNatively() -> UIImagePickerController.CameraDevice {
                    switch self {
                    case .back:
                        return .rear
                    case .front:
                        return .front
                    }
                }
            }
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let cameraModule: NZCameraModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.rootViewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let camera = cameraModule.uiCamera
        camera.cancelHandler = {
            let error = NZError.bridgeFailed(reason: .cancel)
            bridge.invokeCallbackFail(args: args, error: error)
        }
        camera.errorHandler = { [unowned bridge] errmsg in
            let error = NZError.bridgeFailed(reason: .custom(errmsg))
            bridge.invokeCallbackFail(args: args, error: error)
        }
        let compressed = params.sizeType.contains(.compressed)
        if params.type == .photo {
            camera.showTakePhoto(compressed: compressed, to: viewController) { photo in
                bridge.invokeCallbackSuccess(args: args, result: photo)
            }
        } else if params.type == .video {
            camera.showRecordVideo(device: params.cameraDevice?.toNatively() ?? .rear,
                                   maxDuration: params.maxDuration ?? 60,
                                   compressed: compressed,
                                   to: viewController) { video in
                bridge.invokeCallbackSuccess(args: args, result: video)
            }
        }
    }
    
}
