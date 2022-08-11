//
//  MediaAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
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

enum MediaAPI: String, CaseIterableAPI {
   
    case getLocalImage
    case previewImage
    case openNativelyAlbum
    case saveImageToPhotosAlbum
    case getImageInfo
    case compressImage
    case saveVideoToPhotosAlbum
    case getVideoInfo
    case compressVideo
    
    var runInThread: DispatchQueue {
        switch self {
        case .getLocalImage:
            return DispatchQueue.global(qos: .userInteractive)
        case .getImageInfo, .compressImage, .getVideoInfo, .compressVideo:
            return DispatchQueue.global()
        default:
            return DispatchQueue.main
        }
    }
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
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
            case .getImageInfo:
                getImageInfo(appService: appService, bridge: bridge, args: args)
            case .compressImage:
                compressImage(appService: appService, bridge: bridge, args: args)
            case .saveVideoToPhotosAlbum:
                saveVideoToPhotosAlbum(appService: appService, bridge: bridge, args: args)
            case .getVideoInfo:
                getVideoInfo(appService: appService, bridge: bridge, args: args)
            case .compressVideo:
                compressVideo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getLocalImage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let path = params["path"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("path"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var filePath = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: path)
        let isEKFile = filePath != nil
        if !isEKFile {
            filePath = FilePath.appStaticFilePath(appId: appService.appId,
                                                  envVersion: appService.envVersion,
                                                  src: path)
        }
        
        let key = filePath!.absoluteString
        
        if !isEKFile, let cache = appService.localImageCache.get(key) {
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
        if !isEKFile {
            appService.localImageCache.put(key: key, value: dataURL, size: dataURL.bytes.count)
        }
        bridge.invokeCallbackSuccess(args: args, result: ["src": dataURL])
    }
    
    private func previewImage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let current: Int
            let urls: [String]
        }
        
        guard let appSerivce = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.urls.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("urls"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let urls = params.urls.compactMap { url in
            return FilePath.ekFilePathToRealFilePath(appId: appSerivce.appId, filePath: url) ?? URL(string: url)
        }
        
        ImagePreview.show(urls: urls, current: params.current)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func openNativelyAlbum(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let types: [SourceType]
            let sizeType: [SizeType]
            let count: Int
            
            enum SourceType: String, Decodable {
                case photo
                case video
            }
            
            enum SizeType: String, Decodable {
                case original
                case compressed
            }
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.rootViewController else {
            let error = EKError.bridgeFailed(reason: .visibleViewControllerNotFound)
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
            let error = EKError.bridgeFailed(reason: .cancel)
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
                    
                    let (ekfile, filePath) = FilePath.generateTmpEKFilePath(ext: ext)
                    filePaths.append(ekfile)
                    
                    FileManager.default.createFile(atPath: filePath.path, contents: imageData, attributes: nil)
                    files.append(["path": ekfile, "size": imageData.count])
                }
                bridge.invokeCallbackSuccess(args: args, result: ["tempFilePaths": filePaths, "tempFiles": files])
            } else if asset.mediaType == .video {
                let compressed = params.sizeType.contains(.compressed)
                processVideoAssetData(asset: asset, compressed: compressed) { videoData, error in
                    if let error = error {
                        let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
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
    
    private func processVideoAssetData(asset: PHAsset, compressed: Bool, completionHandler: @escaping ((UICameraEngine.VideoData?, Error?) -> Void))  {
        var ext = "unknown"
        let resource = PHAssetResource.assetResources(for: asset).first!
        let uType = resource.uniformTypeIdentifier
        if let fileExtension = UTTypeCopyPreferredTagWithClass(uType as CFString, kUTTagClassFilenameExtension) {
            ext = String(fileExtension.takeRetainedValue())
        }
        
        let (temp, destination) = FilePath.generateTmpEKFilePath(ext: ext)
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        PHAssetResourceManager.default().writeData(for: resource, toFile: destination, options: options) { error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                func notCompress() {
                    let videoData = UICameraEngine.VideoData(tempFilePath: temp,
                                                             duration: asset.duration,
                                                             size: destination.fileSize,
                                                             width: CGFloat(asset.pixelWidth),
                                                             height: CGFloat(asset.pixelHeight))
                    completionHandler(videoData, nil)
                }
                if compressed {
                    VideoUtil.compressVideo(url: destination,
                                            quality: compressed ? .medium : nil,
                                            bitrate: nil,
                                            fps: nil,
                                            resolution: 1.0) { ekfile, fileSize, size, error in
                        if error != nil {
                            notCompress()
                        } else {
                            try? FileManager.default.removeItem(at: destination)
                            let videoData = UICameraEngine.VideoData(tempFilePath: ekfile,
                                                                     duration: asset.duration,
                                                                     size: fileSize,
                                                                     width: size.width,
                                                                     height: size.height)
                            completionHandler(videoData, nil)
                        }
                    }
                } else {
                    notCompress()
                }
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
    
    private func saveImageToPhotosAlbum(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let dict = args.paramsString.toDict(), let filePath = dict["filePath"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("filePath"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: filePath),
              let image = UIImage.init(contentsOfFile: url.path) else {
            let error = EKError.bridgeFailed(reason: .filePathNotExist(filePath))
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
                    bridge.invokeCallbackFail(args: args, error: EKError.custom(error!.localizedDescription))
                }
            }
        }
        
        func denied() {
            let error = EKError.bridgeFailed(reason: .custom("auth denied"))
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
    
    private func loadImage(appId: String,
                           envVersion: AppEnvVersion,
                           src: String,
                           completionHandler handler: @escaping (UIImage?) -> Void) {
        if let url = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: src) {
            handler(UIImage(contentsOfFile: url.path))
        } else if let url = URL(string: src), (url.scheme == "http" || url.scheme == "https") {
            SDWebImageManager.shared.loadImage(with: url, options: [.retryFailed], progress: nil) { image, data, error, _, _, _ in
                handler(image)
            }
        } else if src.starts(with: "data:image") {
            if let start = src.firstIndex(of: ",") {
                let base64 = String(src[src.index(after: start)..<src.endIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
                if let data = Data(base64Encoded: base64) {
                    handler(UIImage(data: data))
                    return
                }
            }
            handler(nil)
        } else {
            let url = FilePath.appStaticFilePath(appId: appId, envVersion: envVersion, src: src)
            handler(UIImage(contentsOfFile: url.path))
        }
    }
    
    private func getImageInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let dict = args.paramsString.toDict(), let src = dict["src"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("src"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        func imageOrientationToString(_ orientation: UIImage.Orientation) -> String {
            switch orientation {
            case .up:
                return "up"
            case .upMirrored:
                return "up-mirrored"
            case .down:
                return "down"
            case .downMirrored:
                return "down-mirrored"
            case .left:
                return "left"
            case .leftMirrored:
                return "left-mirrored"
            case .right:
                return "right"
            case .rightMirrored:
                return "right-mirrored"
            @unknown default:
                return "up"
            }
        }
        
        func imageForamtToString(_ format: SDImageFormat) -> String {
            switch format {
            case .JPEG:
                return "jpeg"
            case .PNG:
                return "png"
            case .GIF:
                return "gif"
            case .TIFF:
                return "tiff"
            default:
                return "unknown"
            }
        }
        
        func imageToBase64(image: UIImage) -> String? {
            guard var data = image.sd_imageData() else { return nil }
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
            case .TIFF:
                format = "tiff"
            default:
                format = "unknown"
            }
            
            let base64 = data.base64EncodedString()
            let dataURL = "data:image/\(format);base64, " + base64
            return dataURL
        }
        
        func result(width: CGFloat, height: CGFloat, orientation: String, type: String, path: String) -> [String: Any] {
            return [
                "width": width,
                "height": height,
                "orientation": orientation,
                "path": path,
                "type": type
            ]
        }
        
        let toBase64 = dict["toBase64"] as? Bool ?? false
        
        loadImage(appId: appService.appId, envVersion: appService.envVersion, src: src) { image in
            if let image = image {
                if toBase64, let path = imageToBase64(image: image) {
                    let result = result(width: image.size.width,
                                        height: image.size.height,
                                        orientation: imageOrientationToString(image.imageOrientation),
                                        type: imageForamtToString(image.sd_imageFormat),
                                        path: path)
                    bridge.invokeCallbackSuccess(args: args, result: result)
                } else if FilePath.isEKFile(filePath: src) {
                    let result = result(width: image.size.width,
                                        height: image.size.height,
                                        orientation: imageOrientationToString(image.imageOrientation),
                                        type: imageForamtToString(image.sd_imageFormat),
                                        path: src)
                    bridge.invokeCallbackSuccess(args: args, result: result)
                } else {
                    let type = imageForamtToString(image.sd_imageFormat)
                    let ext = type == "jpeg" ? "jpg" : type
                    let (ekfile, destination) = FilePath.generateTmpEKFilePath(ext: ext)
                    let data = image.sd_imageData()
                    if FileManager.default.createFile(atPath: destination.path, contents: data) {
                        let result = result(width: image.size.width,
                                            height: image.size.height,
                                            orientation: imageOrientationToString(image.imageOrientation),
                                            type: type,
                                            path: ekfile)
                        bridge.invokeCallbackSuccess(args: args, result: result)
                    } else {
                        bridge.invokeCallbackFail(args: args, error: EKError.custom("create file failed"))
                    }
                }
            } else {
                let error = EKError.bridgeFailed(reason: .custom("load image failed: \(src)"))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        }
    }
    
    private func compressImage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let src: String
            let quality: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.src) {
            if let image = UIImage(contentsOfFile: url.path) {
                let data = image.jpegData(compressionQuality: CGFloat(params.quality / 100))
                let (ekfile, destination) = FilePath.generateTmpEKFilePath(ext: "jpg")
                let success = FileManager.default.createFile(atPath: destination.path, contents: data)
                if success {
                    bridge.invokeCallbackSuccess(args: args, result: ["tempFilePath": ekfile])
                } else {
                    bridge.invokeCallbackFail(args: args, error: EKError.custom("create file failed"))
                }
            } else {
                let error = EKError.bridgeFailed(reason: .filePathNotExist(params.src))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            let url = FilePath.appStaticFilePath(appId: appService.appId, envVersion: appService.envVersion, src: params.src)
            if let image = UIImage(contentsOfFile: url.path) {
                let (ekfile, destination) = FilePath.generateTmpEKFilePath(ext: "jpg")
                let success = FileManager.default.createFile(atPath: destination.path,
                                                             contents: image.sd_imageData())
                if success {
                    bridge.invokeCallbackSuccess(args: args, result: ["tempFilePath": ekfile])
                } else {
                    bridge.invokeCallbackFail(args: args, error: EKError.custom("create file failed"))
                }
            } else {
                let error = EKError.bridgeFailed(reason: .filePathNotExist(params.src))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        }
    }
    
    private func saveVideoToPhotosAlbum(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let dict = args.paramsString.toDict(), let filePath = dict["filePath"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("filePath"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: filePath),
              FileManager.default.fileExists(atPath: url.path) else {
            let error = EKError.bridgeFailed(reason: .filePathNotExist(filePath))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        func save() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { success, error in
                if success {
                    bridge.invokeCallbackSuccess(args: args)
                } else {
                    bridge.invokeCallbackFail(args: args, error: EKError.custom(error!.localizedDescription))
                }
            }
        }
        
        func denied() {
            let error = EKError.bridgeFailed(reason: .custom("auth denied"))
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
    
    private func getVideoInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let dict = args.paramsString.toDict(), let src = dict["src"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("src"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        func _getVideoInfo(url: URL) {
            guard FileManager.default.fileExists(atPath: url.path) else {
                let error = EKError.bridgeFailed(reason: .filePathNotExist(src))
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            
            let asset = AVURLAsset(url: url)
            
            guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                let error = EKError.bridgeFailed(reason: .custom("video track not found"))
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            
            var mimeType = "unknown"
            if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, url.pathExtension as CFString, nil)?.takeRetainedValue() {
                if let _mimeType = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                    mimeType = _mimeType as String
                }
            }
            
            bridge.invokeCallbackSuccess(args: args, result: ["duration": asset.duration.seconds,
                                                              "size": url.fileSize / 1024,
                                                              "width": videoTrack.naturalSize.width,
                                                              "height": videoTrack.naturalSize.height,
                                                              "fps": videoTrack.nominalFrameRate,
                                                              "bitrate": videoTrack.estimatedDataRate,
                                                              "type": mimeType
                                                             ])
        }
        
        if let url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: src) {
            _getVideoInfo(url: url)
        } else {
            let url = FilePath.appStaticFilePath(appId: appService.appId, envVersion: appService.envVersion, src: src)
            _getVideoInfo(url: url)
        }
    }
    
    private func compressVideo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let src: String
            let quality: VideoUtil.CompressQuality?
            let bitrate: Float?
            let fps: Float?
            let resolution: CGFloat
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.src)
        if url == nil {
            url = FilePath.appStaticFilePath(appId: appService.appId, envVersion: appService.envVersion, src: params.src)
        }
        
        if let url = url {
            VideoUtil.compressVideo(url: url, quality: params.quality, bitrate: params.bitrate, fps: params.fps, resolution: params.resolution) { ekfile, fileSize, _, error in
                if let error = error {
                    bridge.invokeCallbackFail(args: args, error: error)
                } else {
                    bridge.invokeCallbackSuccess(args: args, result: ["tempFilePath": ekfile, "size": fileSize])
                }
            }
        } else {
            bridge.invokeCallbackFail(args: args, error: EKError.bridgeFailed(reason: .custom("src invalid")))
        }
    }
}
