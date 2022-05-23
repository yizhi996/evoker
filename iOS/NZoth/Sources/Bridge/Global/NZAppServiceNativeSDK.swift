//
//  NZAppServiceSDK.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol NZAppServiceNativeSDKExport: JSExport {
    
    var system: NZSystemAPI { get }
    
    var timer: NZNativeTimer { get }
    
    var messageChannel: NZMessageChannel { get }
    
    init()

}

@objc public class NZAppServiceNativeSDK: NSObject, NZAppServiceNativeSDKExport {
    
    public var appId = "" {
        didSet {
            system.appId = appId
        }
    }
    
    public var envVersion = NZAppEnvVersion.develop {
        didSet {
            system.envVersion = envVersion
        }
    }
    
    public var system = NZSystemAPI()
    
    public var timer = NZNativeTimer()
    
    public var messageChannel = NZMessageChannel()
    
    override public required init() {
        super.init()
    }
    
}
