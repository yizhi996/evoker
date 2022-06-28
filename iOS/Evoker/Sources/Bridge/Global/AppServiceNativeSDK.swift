//
//  AppServiceSDK.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol AppServiceNativeSDKExport: JSExport {
    
    var timer: NativeTimer { get }
    
    var messageChannel: MessageChannel { get }
    
    var system: SystemObject { get }
    
    var storage: StorageSyncObject { get }
    
    var base64: Base64Object { get }
    
    init()

}

@objc public class AppServiceNativeSDK: NSObject, AppServiceNativeSDKExport {
    
    public var appId = "" {
        didSet {
            system.appId = appId
            storage.appId = appId
        }
    }
    
    public var envVersion = AppEnvVersion.develop {
        didSet {
            system.envVersion = envVersion
            storage.envVersion = envVersion
        }
    }
    
    public var timer = NativeTimer()
    
    public var messageChannel = MessageChannel()
    
    public var system = SystemObject()
    
    public var storage = StorageSyncObject()
    
    public var base64 = Base64Object()
    
    override public required init() {
        super.init()
    }
    
}
