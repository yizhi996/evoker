//
//  NZMediaAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import SDWebImage
import CryptoSwift
import ZLPhotoBrowser
import SDWebImageWebPCoder

enum NZMediaAPI: String, NZBuiltInAPI {
   
    case getLocalImage
    case previewImage
    case openNativelyAlbum
    
    var runInThread: DispatchQueue {
        switch self {
        case .getLocalImage:
            return DispatchQueue.global(qos: .userInteractive)
        default:
            return DispatchQueue.main
        }
    }
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        runInThread.async {
            switch self {
            case .getLocalImage:
                getLocalImage(args: args, bridge: bridge)
            case .previewImage:
                previewImage(args: args, bridge: bridge)
            case .openNativelyAlbum:
                openNativelyAlbum(args: args, bridge: bridge)
            }
        }
    }
    
    private func getLocalImage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let path = params["path"] as? String else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("path"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var filePath = FilePath.nzFilePathToRealFilePath(filePath: path)
        let isNZFile = filePath != nil
        if !isNZFile {
            filePath = FilePath.appStaticFilePath(appId: appService.appId,
                                                  envVersion: appService.envVersion,
                                                  src: path)
        }
        
        let key = filePath!.absoluteString
        
        if !isNZFile, let cache = NZEngine.shared.localImageCache.get(key) {
            bridge.invokeCallbackSuccess(args: args, result: ["src": cache])
            return
        }
        
        guard var data = try? Data(contentsOf: filePath!) else {
            bridge.invokeCallbackFail(args: args, error: .custom("file not exist"))
            return
        }
        
        var mime = NSData.sd_imageFormat(forImageData: data)
        if mime == .webP,
            let image = SDImageWebPCoder.shared.decodedImage(with: data, options: [:]),
            let newData = image.sd_imageData() {
            data = newData
            mime = NSData.sd_imageFormat(forImageData: data)
        }
        
        let format: String
        switch mime {
        case .PNG:
            format = "png"
        case .JPEG:
            format = "jpeg"
        case .SVG:
            format = "svg+xml"
        case .webP:
            format = "webp"
        case .GIF:
            format = "gif"
        default:
            format = "jpeg"
        }
        
        let base64 = data.base64EncodedString()
        let dataURL = "data:image/\(format);base64, " + base64
        if !isNZFile {
            NZEngine.shared.localImageCache.put(key: key, value: dataURL, size: dataURL.bytes.count)
        }
        bridge.invokeCallbackSuccess(args: args, result: ["src": dataURL])
    }
    
    private func previewImage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let params: NZImagePreview.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.urls.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("items"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
       
        NZImagePreview.show(params: params)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func openNativelyAlbum(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let types: [SourceType]
            let count: Int
        }
        
        enum SourceType: String, Decodable {
            case photo
            case video
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.rootViewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let ps = ZLPhotoPreviewSheet()
        let config = ZLPhotoConfiguration.default()
        config.allowTakePhotoInLibrary = false
        config.allowSelectVideo = false
        config.maxSelectCount = params.count
        ps.selectImageBlock = { [unowned bridge] (images, assets, isOriginal) in
            var filePaths: [String] = []
            var files: [[String: Any]] = []
            images.forEach { image in
                let dest = FilePath.createTempNZFilePath(ext: "jpg")
                filePaths.append(dest.1)
                let imageData = image.jpegData(compressionQuality: 1.0)!
                FileManager.default.createFile(atPath: dest.0.path, contents: imageData, attributes: nil)
                let file: [String: Any] = ["path": dest.1, "size": imageData.count]
                files.append(file)
            }
            let result: [String: Any] = ["tempFilePaths": filePaths, "tempFiles": files]
            bridge.invokeCallbackSuccess(args: args, result: result)
        }
        ps.showPhotoLibrary(sender: viewController)
    }
    
}
