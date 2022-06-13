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
    
    var storage: NZStorageSyncAPI { get }
    
    var base64: NZBase64API { get }
    
    init()

}

@objc public class NZAppServiceNativeSDK: NSObject, NZAppServiceNativeSDKExport {
    
    public var appId = "" {
        didSet {
            system.appId = appId
            storage.appId = appId
        }
    }
    
    public var envVersion = NZAppEnvVersion.develop {
        didSet {
            system.envVersion = envVersion
            storage.envVersion = envVersion
        }
    }
    
    public var system = NZSystemAPI()
    
    public var timer = NZNativeTimer()
    
    public var messageChannel = NZMessageChannel()
    
    public var storage = NZStorageSyncAPI()
    
    public var base64 = NZBase64API()
    
    override public required init() {
        super.init()
    }
    
}
