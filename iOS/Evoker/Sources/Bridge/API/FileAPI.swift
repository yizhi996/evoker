//
//  FileAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum FileAPI: String, CaseIterableAPI {
   
    case saveFile
    
    case removeSavedFile
    
    case getSavedFileList
    
    case getSavedFileInfo
    
    case getFileInfo
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        appService.fileQueue.async {
            switch self {
            case .saveFile:
                saveFile(appService: appService, bridge: bridge, args: args)
            case .removeSavedFile:
                removeSavedFile(appService: appService, bridge: bridge, args: args)
            case .getSavedFileList:
                getSavedFileList(appService: appService, bridge: bridge, args: args)
            case .getSavedFileInfo:
                getSavedFileInfo(appService: appService, bridge: bridge, args: args)
            case .getFileInfo:
                getFileInfo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
        
    private func saveFile(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let tempFilePath: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.tempFilePath) {
            let fileName = filePath.lastPathComponent
            let (newEKFile, dest) = FilePath.generateStoreEKFilePath(appId: appService.appId, filename: fileName)
            do {
                let destDirectory = dest.deletingPathExtension()
                if !FileManager.default.fileExists(atPath: destDirectory.path) {
                    try FileManager.default.createDirectory(at: destDirectory, withIntermediateDirectories: true)
                }
                try FileManager.default.moveItem(at: filePath, to: dest)
                bridge.invokeCallbackSuccess(args: args, result: ["savedFilePath": newEKFile])
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            let error = EKError.bridgeFailed(reason: .invalidFilePath(params.tempFilePath))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func removeSavedFile(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let filePath: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.filePath) {
            do {
                try FileManager.default.removeItem(at: filePath)
                bridge.invokeCallbackSuccess(args: args)
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            let error = EKError.bridgeFailed(reason: .invalidFilePath(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getSavedFileList(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let directory = FilePath.store(appId: appService.appId)
        
        var files: [[String: Any]] = []
        
        if !FileManager.default.fileExists(atPath: directory.path) {
            bridge.invokeCallbackSuccess(args: args, result: ["fileList": files])
            return
        }
        
        let resourceKeys = Set<URLResourceKey>([.fileSizeKey, .nameKey, .creationDateKey])
        let directoryEnumerator = FileManager.default.enumerator(at: directory,
                                                                 includingPropertiesForKeys: Array(resourceKeys))!
        
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                let name = resourceValues.name else { continue }
            let file = ["filePath": "ekfile://store_\(name)",
                        "size": resourceValues.fileSize ?? 0,
                        "createTime": Int((resourceValues.creationDate?.timeIntervalSince1970 ?? 0))] as [String : Any]
            files.append(file)
        }
        bridge.invokeCallbackSuccess(args: args, result: ["fileList": files])
    }
        
    private func getSavedFileInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let filePath: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.filePath) {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                let error = EKError.bridgeFailed(reason: .filePathNotExist(params.filePath))
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            
            do {
                let resourceValues = try filePath.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                let file = ["size": resourceValues.fileSize ?? 0,
                            "createTime": Int((resourceValues.creationDate?.timeIntervalSince1970 ?? 0))] as [String : Any]
                bridge.invokeCallbackSuccess(args: args, result: file)
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            let error = EKError.bridgeFailed(reason: .invalidFilePath(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func getFileInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let filePath: String
            let digestAlgorithm: DigestAlgorithm
            
            enum DigestAlgorithm: String, Decodable {
                case md5
                case sha1
            }
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: params.filePath) {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                let error = EKError.bridgeFailed(reason: .filePathNotExist(params.filePath))
                bridge.invokeCallbackFail(args: args, error: error)
                return
            }
            
            do {
                let resourceValues = try filePath.resourceValues(forKeys: [.fileSizeKey])
                var file = ["size": resourceValues.fileSize ?? 0] as [String : Any]
                
                var digest = ""
                if params.digestAlgorithm == .md5 {
                    digest = calcuateFileMD5(url: filePath) ?? ""
                } else if params.digestAlgorithm == .sha1 {
                    digest = calcuateFileSHA1(url: filePath) ?? ""
                }
                file["digest"] = digest
                bridge.invokeCallbackSuccess(args: args, result: file)
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            let error = EKError.bridgeFailed(reason: .invalidFilePath(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
}
