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

@objc protocol AppServiceNativeSDKExport: JSExport {
    
    var timer: NativeTimer { get }
    
    var messageChannel: MessageChannel { get }
    
    var system: SystemObject { get }
    
    var storage: StorageSyncObject { get }
    
    var base64: Base64Object { get }
    
    var fileSystemManager: FileSystemManagerObject { get }
    
    init()
    
    func evalWebView(_ script: String, _ webViewId: Int) -> Any?
    
    func shareAppMessage(_ title: String, _ path: String, _ imageUrl: String)

}

@objc class AppServiceNativeSDK: NSObject, AppServiceNativeSDKExport {
    
    var appId = "" {
        didSet {
            system.appId = appId
            storage.appId = appId
            fileSystemManager.appId = appId
        }
    }
    
    var envVersion = AppEnvVersion.develop {
        didSet {
            system.envVersion = envVersion
            storage.envVersion = envVersion
            fileSystemManager.envVersion = envVersion
        }
    }
    
    var timer = NativeTimer()
    
    var messageChannel = MessageChannel()
    
    var system = SystemObject()
    
    var storage = StorageSyncObject()
    
    var base64 = Base64Object()
    
    var fileSystemManager = FileSystemManagerObject()
    
    override required init() {
        super.init()
    }
    
    func evalWebView(_ script: String, _ webViewId: Int) -> Any? {
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
    
    func shareAppMessage(_ title: String, _ path: String, _ imageUrl: String) {
        guard let appService = Engine.shared.getAppService(appId: appId, envVersion: envVersion) else { return }
        
        let content = ShareAppMessageContent(title: title, path: path, imageUrl: imageUrl)
        Engine.shared.config.hooks.app.shareAppMessage?(appService, content)
    }
}
