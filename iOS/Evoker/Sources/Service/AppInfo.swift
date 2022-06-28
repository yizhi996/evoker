//
//  AppInfo.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

public struct AppInfo {
    
    public var appName: String = ""
    
    public var appIconURL: String = ""
    
    public var userInfo: [String: Any] = [:]
        
    public init(appName: String, appIconURL: String, userInfo: [String: Any] = [:]) {
        self.appName = appName
        self.appIconURL = appIconURL
        self.userInfo = userInfo
    }
}
