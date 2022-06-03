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
import Photos
import MobileCoreServices

enum NZMediaAPI: String, NZBuiltInAPI {
   
    case getLocalImage
    case previewImage
    case openNativelyAlbum
    case saveImageToPhotosAlbum
    
    var runInThread: DispatchQueue {
        switch self {
        case .getLocalImage:
            return DispatchQueue.global(qos: .userInteractive)
        default:
            return DispatchQueue.main
        }
    }
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        runInThread.async {
            switch self {
            case .getLocalImage:
                getLocalImage(appService: appService, bridge: bridge, args: args)
            case .previewImage:
                previewImage(appService: appService, bridge: bridge, args: args)
            case .openNativelyAlbum:
                openNativelyAlbum(appService: appService, bridge: bridge, args: args)
            case .saveImageToPhotosAlbum:
                saveImageToPhotosAlbum(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getLocalImage(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
        
        var filePath = FilePath.nzFilePathToRealFilePath(appId: appService.appId, filePath: path)
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
    
    private func previewImage(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let current: Int
            let urls: [String]
        }
        
        guard let appSerivce = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.urls.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("urls"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let urls = params.urls.compactMap { url in
            return FilePath.nzFilePathToRealFilePath(appId: appSerivce.appId, filePath: url) ?? URL(string: url)
        }
        
        NZImagePreview.show(urls: urls, current: params.current)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func openNativelyAlbum(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let types: [SourceType]
            let sizeType: [SizeType]
            let count: Int
        }
        
        enum SourceType: String, Decodable {
            case photo
            case video
        }
        
        enum SizeType: String, Decodable {
            case original
            case compressed
        }
        
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
        config.allowSelectVideo = params.types.contains(.video)
        config.allowSelectImage = params.types.contains(.photo)
        config.allowSelectOriginal = params.sizeType.count == 2
        config.maxSelectCount = params.count
        
        ps.cancelBlock = { [unowned bridge] in
            let error = NZError.bridgeFailed(reason: .cancel)
            bridge.invokeCallbackFail(args: args, error: error)
        }
        ps.selectImageBlock = { [unowned bridge] (images, assets, isOriginal) in
           
            func getOriginalImage(asset: PHAsset, image: UIImage) -> (Data, String) {
                let ext = imageAssetGetExt(asset: asset)
                let fmt = extToForamt(ext: ext)
                let data = image.sd_imageData(as: fmt)!
                return (data, ext)
            }
            
            guard !assets.isEmpty else { return }
            
            let asset = assets[0]
            if asset.mediaType == .image {
                var filePaths: [String] = []
                var files: [[String: Any]] = []
                for (i, image) in images.enumerated() {
                    var ext = "jpg"
                    let asset = assets[i]
                    var imageData: Data
                    if params.sizeType.count == 2 {
                        if isOriginal {
                            (imageData, ext) = getOriginalImage(asset: asset, image: image)
                        } else {
                            ext = "jpg"
                            imageData = image.jpegData(compressionQuality: 0.7)!
                        }
                    } else if params.sizeType.contains(.original) {
                        (imageData, ext) = getOriginalImage(asset: asset, image: image)
                    } else {
                        if imageAssetGetExt(asset: asset) == "gif" {
                            ext = "gif"
                            imageData = image.sd_imageData(as: .GIF)!
                        } else {
                            ext = "jpg"
                            let size = ZLPhotoModel(asset: asset).previewSize
                            let newImage = image.sd_resizedImage(with: size, scaleMode: SDImageScaleMode.fill)!
                            imageData = newImage.jpegData(compressionQuality: 0.7)!
                        }
                    }
                    
                    let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: ext)
                    filePaths.append(nzfile)
                    
                    FileManager.default.createFile(atPath: filePath.path, contents: imageData, attributes: nil)
                    files.append(["path": nzfile, "size": imageData.count])
                }
                bridge.invokeCallbackSuccess(args: args, result: ["tempFilePaths": filePaths, "tempFiles": files])
            } else if asset.mediaType == .video {
                getVideoAssetData(asset: asset) { videoData, error in
                    if let error = error {
                        let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                        bridge.invokeCallbackFail(args: args, error: error)
                    } else if let videoData = videoData {
                        bridge.invokeCallbackSuccess(args: args, result: videoData)
                    }
                }
            }
        }
        ps.showPhotoLibrary(sender: viewController)
    }
    
    private func imageAssetGetExt(asset: PHAsset) -> String {
        var ext = "jpg"
        if let uType = PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier {
            if let fileExtension = UTTypeCopyPreferredTagWithClass(uType as CFString,
                                     kUTTagClassFilenameExtension) {
                ext = String(fileExtension.takeRetainedValue())
            }
        }
        let allowExts = ["jpg", "jpeg", "png", "gif", "webp"]
        if !allowExts.contains(ext) {
            ext = "jpg"
        }
        return ext
    }
    
    private func getVideoAssetData(asset: PHAsset, completionHandler: @escaping ((UICameraEngine.VideoData?, Error?) -> Void))  {
        var ext = "mov"
        let resource = PHAssetResource.assetResources(for: asset).first!
        let uType = resource.uniformTypeIdentifier
        if let fileExtension = UTTypeCopyPreferredTagWithClass(uType as CFString, kUTTagClassFilenameExtension) {
            ext = String(fileExtension.takeRetainedValue())
        }
        let allowExts = ["mov", "mp4"]
        if !allowExts.contains(ext) {
            ext = "mov"
        }
        
        let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: ext)
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = false
        PHAssetResourceManager.default().writeData(for: resource, toFile: filePath, options: options) { error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                let videoData = UICameraEngine.VideoData(tempFilePath: nzfile,
                                                         duration: asset.duration,
                                                         size: filePath.fileSize,
                                                         width: CGFloat(asset.pixelWidth),
                                                         height: CGFloat(asset.pixelHeight))
                completionHandler(videoData, nil)
            }
        }
    }
    
    private func extToForamt(ext: String) -> SDImageFormat {
        var fmt = SDImageFormat.JPEG
        if ext == "jpg" || ext == "jpeg" {
            fmt = SDImageFormat.JPEG
        } else if ext == "png" {
            fmt = SDImageFormat.PNG
        } else if ext == "gif" {
            fmt = SDImageFormat.GIF
        } else if ext == "webp" {
            fmt = SDImageFormat.webP
        }
        return fmt
    }
    
    private func saveImageToPhotosAlbum(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let dict = args.paramsString.toDict(), let filePath = dict["filePath"] as? String else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("filePath"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let url = FilePath.nzFilePathToRealFilePath(appId: appService.appId, filePath: filePath),
              let image = UIImage.init(contentsOfFile: url.path) else {
            let error = NZError.bridgeFailed(reason: .filePathNotExist(filePath))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        func save() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if success {
                    bridge.invokeCallbackSuccess(args: args)
                } else {
                    bridge.invokeCallbackFail(args: args, error: NZError.custom(error!.localizedDescription))
                }
            }
        }
        
        func denied() {
            let error = NZError.bridgeFailed(reason: .custom("auth denied"))
            bridge.invokeCallbackFail(args: args, error: error)
        }
        
        switch PrivacyPermission.album {
        case .authorized:
            save()
        case .denied:
            denied()
        case .notDetermined:
            PrivacyPermission.requestAlbum {
                if PrivacyPermission.album == .authorized {
                    save()
                } else {
                    denied()
                }
            }
        }
        
    }
}
