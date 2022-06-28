//
//  StorageAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum StorageAPI: String, CaseIterableAPI {
   
    case getStorage
    case setStorage
    case removeStorage
    case clearStorage
    case getStorageInfo
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.global().async {
            switch self {
            case .getStorage:
                getStorage(appService: appService, bridge: bridge, args: args)
            case .setStorage:
                setStorage(appService: appService, bridge: bridge, args: args)
            case .removeStorage:
                removeStorage(appService: appService, bridge: bridge, args: args)
            case .clearStorage:
                clearStorage(appService: appService, bridge: bridge, args: args)
            case .getStorageInfo:
                getStorageInfo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getStorage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = EVError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let (result, error) = appService.storage.get(key: key)
        if let result = result {
            bridge.invokeCallbackSuccess(args: args, result: ["data": result.0, "dataType": result.1])
        } else if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func setStorage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = EVError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let data = params["data"] as? String else {
            let error = EVError.bridgeFailed(reason: .fieldRequired("data"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let dataType = params["dataType"] as? String, !dataType.isEmpty else {
            let error = EVError.bridgeFailed(reason: .fieldRequired("dataType"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.set(key: key, data: data, dataType: dataType) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func removeStorage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = EVError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.remove(key: key) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func clearStorage(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        if let error = appService.storage.clear() {
           bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func getStorageInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let (result, error) = appService.storage.info()
        if let (keys, size, limit) = result {
            bridge.invokeCallbackSuccess(args: args, result: ["keys": keys, "currentSize": size, "limitSize": limit])
        } else if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }

}
