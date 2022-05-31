//
//  NZStorageSyncAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol NZStorageSyncAPIExport: JSExport {
    
    init()
    
    func getStorageSync(_ key: String) -> [String: Any]
    
    func setStorageSync(_ key: String, _ data: String, _ dataType: String) -> [String: Any]
    
    func getStorageInfoSync() -> [String: Any]
    
    func removeStorageSync(_ key: String) -> [String: Any]
    
    func clearStorageSync() -> [String: Any]
}

@objc public class NZStorageSyncAPI: NSObject, NZStorageSyncAPIExport {
        
    var appId = ""
    
    var envVersion = NZAppEnvVersion.develop
    
    override public required init() {
        super.init()
    }
    
    public func getStorageSync(_ key: String) -> [String: Any] {
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let (result, error) = appService.storage.get(key: key)
            if let result = result {
                return ["result": ["data": result.0, "dataType": result.1]]
            } else if let error = error {
                return ["errMsg": error.localizedDescription]
            }
        }
        return ["errMsg": NZError.bridgeFailed(reason: .appServiceNotFound).localizedDescription]
    }
    
    public func setStorageSync(_ key: String, _ data: String, _ dataType: String) -> [String: Any] {
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            if let error = appService.storage.set(key: key, data: data, dataType: dataType) {
                return ["errMsg": error.localizedDescription]
            } else {
                return [:]
            }
        }
        return ["errMsg": NZError.bridgeFailed(reason: .appServiceNotFound).localizedDescription]
    }
    
    public func getStorageInfoSync() -> [String: Any] {
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let (result, error) = appService.storage.info()
            if let (keys, size, limit) = result {
                return ["result": ["keys": keys, "currentSize": size, "limitSize": limit]]
            } else if let error = error {
                return ["errMsg": error.localizedDescription]
            }
        }
        return ["errMsg": NZError.bridgeFailed(reason: .appServiceNotFound).localizedDescription]
    }
    
    public func removeStorageSync(_ key: String) -> [String: Any] {
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let error = appService.storage.remove(key: key)
            if let error = error {
                return ["errMsg": error.localizedDescription]
            }
            return [:]
        }
        return ["errMsg": NZError.bridgeFailed(reason: .appServiceNotFound).localizedDescription]
    }
    
    public func clearStorageSync() -> [String: Any] {
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let error = appService.storage.clear()
            if let error = error {
                return ["errMsg": error.localizedDescription]
            }
            return [:]
        }
        return ["errMsg": NZError.bridgeFailed(reason: .appServiceNotFound).localizedDescription]
    }
}
