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
        
        struct Params: Codable  {
            let parentId: String
            let cameraId: Int
            let mode: NZCapture.Mode
            let devicePosition: DevicePosition
            let resolution: Resolution
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
        
        guard let container = UIView.findTongCengContainerView(view: webView,
                                                               tongcengId: params.parentId) else {
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
                bridge.subscribeHandler(method: NZCameraEngine.initDoneSubscribeKey, data: data)
            }
            cameraEngine.errorHandler = { error in
                let data: [String: Any] = ["cameraId": params.cameraId, "error": error]
                bridge.subscribeHandler(method: NZCameraEngine.initErrorSubscribeKey, data: data)
            }
            cameraEngine.scanCodeHandler = { value, _ in
                let data: [String: Any] = ["cameraId": params.cameraId, "value": value]
                bridge.subscribeHandler(method: NZCameraEngine.scanCodeSubscribeKey, data: data)
            }
            cameraEngine.startRunning()
            cameraEngine.addPreviewTo(container)
            cameraModule.cameras[page.pageId] = cameraEngine
            bridge.invokeCallbackSuccess(args: args)
        }
        
        let denied = {
            let data: [String: Any] = ["cameraId": params.cameraId, "error": NZCaptureError.permissionDenied]
            bridge.subscribeHandler(method: NZCameraEngine.initErrorSubscribeKey, data: data)
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
                    let dest = FilePath.createTempNZFilePath(ext: "jpg")
                    let rootDirectory = FilePath.nzFileDirectory()
                    do {
                        try FilePath.createDirectory(at: rootDirectory)
                    } catch {
                        bridge.invokeCallbackFail(args: args, error: .custom("take photo save data fail"))
                        return
                    }
                    if FileManager.default.createFile(atPath: dest.0.path, contents: data, attributes: nil) {
                        bridge.invokeCallbackSuccess(args: args, result: ["tempImagePath": dest.1])
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
            let type: UICameraEngine.CaptureType
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
        
        if params.type == .photo {
            let camera = cameraModule.uiCamera
            camera.takePhotoHandler = { photo in
                bridge.invokeCallbackSuccess(args: args, result: photo)
            }
            camera.showTakePhoto(compressed: false, to: viewController)
        } else if params.type == .video {
            let camera = cameraModule.uiCamera
            camera.recordVideoHandler = { video in
                bridge.invokeCallbackSuccess(args: args, result: video)
            }
            camera.showRecordVideo(compressed: false, to: viewController)
        }
    }
    
}
