//
//  AppServiceSDK.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

public struct ShareAppMessageContent {
    
    public let title: String
    
    public let path: String
    
    public let imageUrl: String?
}

@objc public protocol AppServiceNativeSDKExport: JSExport {
    
    var timer: NativeTimer { get }
    
    var messageChannel: MessageChannel { get }
    
    var system: SystemObject { get }
    
    var storage: StorageSyncObject { get }
    
    var base64: Base64Object { get }
    
    init()
    
    func evalWebView(_ script: String, _ webViewId: Int) -> Any?
    
    func shareAppMessage(_ title: String, _ path: String, _ imageUrl: String)

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
    
    public func evalWebView(_ script: String, _ webViewId: Int) -> Any? {
        guard let appService = Engine.shared.getAppService(appId: appId, envVersion: envVersion) else { return nil }
        
        guard let webPage = appService.findWebPage(from: webViewId) else { return nil }
        
        let group = DispatchGroup()
        group.enter()
        var result: Any? = nil
        DispatchQueue.main.async {
            webPage.webView.evaluateJavaScript(script) { res, _ in
                result = res
                group.leave()
            }
        }
        group.wait()
        return result
    }
    
    public func shareAppMessage(_ title: String, _ path: String, _ imageUrl: String) {
        guard let appService = Engine.shared.getAppService(appId: appId, envVersion: envVersion) else { return }
        
        let content = ShareAppMessageContent(title: title, path: path, imageUrl: imageUrl)
        Engine.shared.config.hooks.app.shareAppMessage?(appService, content)
    }
}
