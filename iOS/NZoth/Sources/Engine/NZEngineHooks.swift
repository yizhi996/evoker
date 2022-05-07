//
//  NZEngineHooks.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

public class NZEngineHooks {
    
    public static let shared = NZEngineHooks()
    
    public class OpenAPI {
        
        public typealias Callback = (NZAppService, NZJSBridge, NZJSBridge.InvokeArgs) -> (Void)
        
        public var login: Callback?
        
        public var checkSession: Callback?
        
        public var getUserInfo: Callback?
        
        public var getUserProfile: Callback?
        
    }
    
    public class App {
        
        public typealias GetAppInfoCompletionHandler = (NZAppInfo) -> Void
        /// App 在启动时需要获取 App Info
        public var getAppInfo: ((String, NZAppEnvVersion, GetAppInfoCompletionHandler) -> Void)?
        
        public var checkAppUpdate: ((String, NZAppEnvVersion, String, String, NZBoolBlock) -> Void)?
    }
    
    public let openAPI = OpenAPI()
    
    public let app = App()
    
    private init() {
        
    }

}

