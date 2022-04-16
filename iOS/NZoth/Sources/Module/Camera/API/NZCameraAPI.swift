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
    case updateCamera
    case operateCamera
    case openNativelyCamera
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertCamera:
                insertCamera(appService: appService, bridge: bridge, args: args)
            case .updateCamera:
                updateCamera(appService: appService, bridge: bridge, args: args)
            case .operateCamera:
                operateCamera(appService: appService, bridge: bridge, args: args)
            case .openNativelyCamera:
                openNativelyCamera(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertCamera(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable  {
            let parentId: String
            let cameraId: Int
            let mode: NZCameraEngine.Options.Mode
            let devicePosition: NZCameraEngine.DevicePosition
            let resolution: NZCameraEngine.Resolution
            let flash: NZCameraEngine.FlashMode
        }

        guard let webView = bridge.container as? NZWebView, let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: NZCameraModule = appService.getModule() else {
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
            let options = NZCameraEngine.Options(mode: params.mode,
                                                 resolution: params.resolution,
                                                 devicePosition: params.devicePosition,
                                                 flashMode: params.flash,
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
            module.cameras[page.pageId] = cameraEngine
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
    
    private func updateCamera(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable  {
            let devicePosition: NZCameraEngine.DevicePosition
            let flash: NZCameraEngine.FlashMode
        }

        guard let webView = bridge.container as? NZWebView, let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: NZCameraModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let camera = module.cameras[page.pageId] else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        camera.flashMode = params.flash
        camera.changeCameraDevicePosition(to: params.devicePosition)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateCamera(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let cameraId: Int
            let method: Method
            let data: Data
            
            enum Method: String, Decodable {
                case takePhoto
                case startRecord
                case stopRecord
                case setZoom
            }
            
            enum Data: Decodable {
                case takePhoto(TakePhotoData)
                case stopRecord(StopRecordData)
                case setZoom(SetZoomData)
                case unknown
                
                struct TakePhotoData: Decodable {
                    let quality: Quality
                    
                    enum Quality: String, Decodable {
                        case low
                        case normal
                        case high
                        
                        func toNumber() -> CGFloat {
                            switch self {
                            case .low:
                                return 0.3
                            case .normal:
                                return 0.7
                            case .high:
                                return 1.0
                                
                            }
                        }
                    }
                }
                
                struct StopRecordData: Decodable {
                    let compressed: Bool
                }
                
                struct SetZoomData: Decodable {
                    let zoom: CGFloat
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let data = try? container.decode(TakePhotoData.self) {
                        self = .takePhoto(data)
                        return
                    }
                    if let data = try? container.decode(StopRecordData.self) {
                        self = .stopRecord(data)
                        return
                    }
                    if let data = try? container.decode(SetZoomData.self) {
                        self = .setZoom(data)
                        return
                    }
                    self = .unknown
                }
            }
        }

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
        
        guard let module: NZCameraModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZCameraModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let cameraEngine = module.cameras[page.pageId] else {
            let error = NZError.bridgeFailed(reason: .cameraNotFound(params.cameraId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .takePhoto:
            if case .takePhoto(let data) = params.data {
                cameraEngine.takePhoto(quality: data.quality.toNumber()) { nzfile, error in
                    if let error = error {
                        let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else if let nzfile = nzfile {
                        bridge.invokeCallbackSuccess(args: args, result: ["tempImagePath": nzfile])
                    } else {
                        bridge.invokeCallbackFail(args: args, error: .custom("take photo fail"))
                    }
                }
            }
        case .startRecord:
            cameraEngine.startRecording { error in
                if let error = error {
                    let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                    bridge.invokeCallbackFail(args: args, error: error)
                } else {
                    bridge.invokeCallbackSuccess(args: args)
                }
            }
        case .stopRecord:
            if case .stopRecord(let data) = params.data {
                cameraEngine.stopRecord(compressed: data.compressed) { video, poster, error in
                    if let error = error {
                        let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else {
                        bridge.invokeCallbackSuccess(args: args,
                                                     result: ["tempThumbPath": poster, "tempVideoPath": video])
                    }
                }
            }
        case .setZoom:
            if case .setZoom(let data) = params.data {
                cameraEngine.setZoom(data.zoom) { error in
                    if let error = error {
                        let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else {
                        bridge.invokeCallbackSuccess(args: args)
                    }
                }
            }
        }
    }
    
    private func openNativelyCamera(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
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
