//
//  NZAppInfo.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

public struct NZAppInfo {
    
    public var appName: String = ""
    
    public var appIconURL: String = ""
    
    public var userInfo: [String: Any] = [:]
        
    public init(appName: String, appIconURL: String, userInfo: [String: Any] = [:]) {
        self.appName = appName
        self.appIconURL = appIconURL
        self.userInfo = userInfo
    }
}

public enum NZAppEnvVersion: String {
    
    case develop
    
    case trail
    
    case release
  
}

public struct NZAppEnterReferrerInfo {
    
    let appId: String
    
    let extraDataString: String?
}

public protocol NZAppEnterOptions {
    
    var path: String { get set }
    
    var referrerInfo: NZAppEnterReferrerInfo? { get set }
    
}

public struct NZAppLaunchOptions: NZAppEnterOptions {
        
    public var path: String = ""
    
    public var referrerInfo: NZAppEnterReferrerInfo?
    
    public var envVersion: NZAppEnvVersion = .release
    
    public init() {
        
    }
}

public struct NZAppShowOptions: NZAppEnterOptions {
    
    public var path: String = ""
    
    public var referrerInfo: NZAppEnterReferrerInfo?
    
    public init() {
        
    }
}
