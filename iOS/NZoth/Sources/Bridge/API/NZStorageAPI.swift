//
//  NZStorageAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZStorageAPI: String, NZBuiltInAPI {
   
    case getStorage
    case setStorage
    case removeStorage
    case clearStorage
    case getStorageInfo
    
    var runInThread: DispatchQueue {
        return DispatchQueue.global()
    }
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        runInThread.async {
            switch self {
            case .getStorage:
                getStorage(args: args, bridge: bridge)
            case .setStorage:
                setStorage(args: args, bridge: bridge)
            case .removeStorage:
                removeStorage(args: args, bridge: bridge)
            case .clearStorage:
                clearStorage(args: args, bridge: bridge)
            case .getStorageInfo:
                getStorageInfo(args: args, bridge: bridge)
            }
        }
    }
    
    private func getStorage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let result = appService.storage.get(key: key)
        if let data = result.0 {
            bridge.invokeCallbackSuccess(args: args, result: ["data": data.0, "dataType": data.1])
        } else if let error = result.1 {
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func setStorage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let data = params["data"] as? String else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("data"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let dataType = params["dataType"] as? String, !dataType.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("dataType"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.set(key: key, data: data, dataType: dataType) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func removeStorage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let error = appService.storage.remove(key: key) {
            bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func clearStorage(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        if let error = appService.storage.clear() {
           bridge.invokeCallbackFail(args: args, error: error)
        } else {
            bridge.invokeCallbackSuccess(args: args)
        }
    }
    
    private func getStorageInfo(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        let (result, error) = appService.storage.info()
        if let (keys, size, limit) = result {
            bridge.invokeCallbackSuccess(args: args, result: ["keys": keys, "currentSize": size, "limitSize": limit])
        } else if let error = error {
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }

}
