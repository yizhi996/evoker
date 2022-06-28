//
//  EngineConfig.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public class EngineConfig {
    
    public let hooks = Hooks()
    
    public let classes = Classes()
    
    public var dev = DevConfig()
    
    init() {
        
    }

}

extension EngineConfig {
    
    public class Classes {
        
        public var webPage: WebPage.Type = WebPage.self
        
        public var browserPage: BrowserPage.Type = BrowserPage.self
    }
}

extension EngineConfig {
    
    public class Hooks {
        
        public class OpenAPI {
            
            public typealias Callback = (AppService, JSBridge, JSBridge.InvokeArgs) -> (Void)
            
            public var login: Callback?
            
            public var checkSession: Callback?
            
            public var getUserInfo: Callback?
            
            public var getUserProfile: Callback?
            
        }
        
        public class App {
            
            public typealias GetAppInfoCompletionHandler = (AppInfo?, EVError?) -> Void
            
            /// App 在启动时需要获取 App Info
            public var getAppInfo: ((String, AppEnvVersion, GetAppInfoCompletionHandler) -> Void)?
            
            public var checkAppUpdate: ((String, AppEnvVersion, String, String, BoolBlock) -> Void)?
            
            /// 自定义点击胶囊的更多按钮时显示的 action
            /// - returns:
            /// 第一个数组是第一行，第二个数组是第二行，第三个 Bool 表示是否在第二行的最前面加入内置的 action（包含设置和重启）
            public var fetchAppMoreActionSheetItems: ((AppService) -> ([AppMoreAction], [AppMoreAction], Bool))?
            
            /// 点击自定义的 AppMoreAction 时执行，可根据 key 判断需要执行的事件
            public var clickAppMoreAction: ((AppService, AppMoreAction) -> Void)?
            
            public class LifeCycle {
                
                public var onLaunch: ((AppService, AppLaunchOptions) -> Void)?
                
                public var onShow: ((AppService, AppShowOptions) -> Void)?
                
                public var onHide: ((AppService) -> Void)?
            }
            
            public let lifeCycle = LifeCycle()
        }
        
        public let openAPI = OpenAPI()
        
        public let app = App()
        
        init() {
            
        }
    }
}

extension EngineConfig {
    
    public struct DevConfig {
        
        public var useDevJSSDK = false
        
        public var useDevServer = false

        init() {
            
        }
    }
}
