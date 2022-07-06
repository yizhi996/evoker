//
//  EVError.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public enum EVError: Error {
    
    case loadAppConfigFailed
    
    case appServiceBundleNotFound
    
    case appLaunchPathNotFound(String)
    
    case appRootViewControllerNotFound
    
    case presentViewControllerNotFound
    
    case httpRequestFailed
    
    case createURLFailed(String)
    
    case storageFailed(reason: StorageFailureReason)
    
    case bridgeFailed(reason: BridgeFailureReason)
    
    case custom(String)
    
    public enum StorageFailureReason {
        
        case connectFailed
        
        case sizeLimited
        
        case singleKeySizeLimit
        
        case getFailed
        
        case setFailed
        
        case removeFailed
        
        case clearFailed
        
        case getInfoFailed
        
        case keyNotExist(String)
    }
 
    public enum BridgeFailureReason {
        
        case cancel
        
        case eventNotDefined
        
        case appServiceNotFound
        
        case pageNotFound
        
        case webViewNotFound
        
        case moduleNotFound(String)
        
        case jsonParseFailed
        
        case fieldRequired(String)
        
        case networkError(String)
        
        case visibleViewControllerNotFound
        
        case filePathNotExist(String)
        
        case contentNotFound
        
        case tongCengContainerViewNotFound(String)
        
        case videoPlayerIdNotFound(Int)
        
        case cameraNotFound(Int)
        
        case inputNotFound(Int)
        
        case storageSizeLimited
        
        case cannotToTabbarPage
        
        case apiHookNotImplemented
        
        case custom(String)
    }
}

extension EVError.StorageFailureReason {
    
    var localizedDescription: String {
        switch self {
        case .connectFailed:
            return "storage connect failed"
        case .singleKeySizeLimit:
            return "a single key can not be large than 1MB"
        case .sizeLimited:
            return "storage all keys can not be large than 10MB"
        case .getFailed:
            return "storage set failed"
        case .setFailed:
            return "storage set failed"
        case .removeFailed:
            return "storage remove failed"
        case .clearFailed:
            return "storage clear failed"
        case .getInfoFailed:
            return "storage get info failed"
        case .keyNotExist(let key):
            return "storage key: \(key) not exist"
        }
    }
}

extension EVError.BridgeFailureReason {
    
    var localizedDescription: String {
        switch self {
        case .cancel:
            return "cancel"
        case .eventNotDefined:
            return "this event not defined"
        case .appServiceNotFound:
            return "app serivce not found"
        case .pageNotFound:
            return "page not found"
        case .webViewNotFound:
            return "web view not found"
        case .jsonParseFailed:
            return "JSON parse failed"
        case .fieldRequired(let filed):
            return "filed -\(filed)- is required"
        case .networkError(let error):
            return error
        case .visibleViewControllerNotFound:
            return "visible view controller not found"
        case .tongCengContainerViewNotFound(let tongcengId):
            return "tongcengId: \(tongcengId) tongCeng container view not found"
        case .videoPlayerIdNotFound(let playerId):
            return "video player id \(playerId) not found"
        case .filePathNotExist(let filePath):
            return "filePath \(filePath) not exist"
        case .moduleNotFound(let module):
            return "module \(module) not found"
        case .cameraNotFound(let id):
            return "camera id: \(id) not found"
        case .inputNotFound(let id):
            return "input id: \(id) not found"
        case .storageSizeLimited:
            return "storage size limited"
        case .cannotToTabbarPage:
            return "cannot to tabbar page"
        case .apiHookNotImplemented:
            return "api hook not implemented, see EngineConfig.hooks"
        case .contentNotFound:
            return "content not found"
        case .custom(let error):
            return "\(error)"
        }
    }
}

extension EVError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .loadAppConfigFailed:
            return "load app.json failed"
        case .appServiceBundleNotFound:
            return "app-service.js not found"
        case .appLaunchPathNotFound(let path):
            return "app launch failed, path: \(path) not found"
        case .appRootViewControllerNotFound:
            return "app root viewController not found"
        case .presentViewControllerNotFound:
            return "present viewController not found"
        case .createURLFailed(let url):
            return "illegal url: \(url)"
        case .httpRequestFailed:
            return "http request fail"
        case let .bridgeFailed(reason):
            return reason.localizedDescription
        case let .storageFailed(reason):
            return reason.localizedDescription
        case let .custom(error):
            return "\(error)"
        }
    }
}
