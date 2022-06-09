//
//  NZEngineConfig.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public class NZEngineConfig {
    
    public static let shared = NZEngineConfig()
    
    public let hooks = Hooks()
    
    public let classes = Classes()
    
    public var dev = DevConfig()
    
    init() {
        
    }
       
}

extension NZEngineConfig {
    
    public class Classes {
        
        public var webPage: NZWebPage.Type = NZWebPage.self
        
        public var browserPage: NZBrowserPage.Type = NZBrowserPage.self
    }
}

extension NZEngineConfig {
    
    public class Hooks {
        
        public class OpenAPI {
            
            public typealias Callback = (NZAppService, NZJSBridge, NZJSBridge.InvokeArgs) -> (Void)
            
            public var login: Callback?
            
            public var checkSession: Callback?
            
            public var getUserInfo: Callback?
            
            public var getUserProfile: Callback?
            
        }
        
        public class App {
            
            public typealias GetAppInfoCompletionHandler = (NZAppInfo?, NZError?) -> Void
            
            /// App 在启动时需要获取 App Info
            public var getAppInfo: ((String, NZAppEnvVersion, GetAppInfoCompletionHandler) -> Void)?
            
            public var checkAppUpdate: ((String, NZAppEnvVersion, String, String, NZBoolBlock) -> Void)?
            
            /// 自定义点击胶囊的更多按钮时显示的 action
            /// - returns:
            /// 第一个数组是第一行，第二个数组是第二行，第三个 Bool 表示是否在第二行的最前面加入内置的 action（包含设置和重启）
            public var fetchAppMoreActionSheetItems: ((NZAppService) -> ([NZAppMoreActionItem], [NZAppMoreActionItem], Bool))?
            
            /// 点击自定义的 NZAppMoreActionItem 时执行，可根据 key 判断需要执行的事件
            public var clickAppMoreActionItem: ((NZAppService, NZAppMoreActionItem) -> Void)?
            
            public class LifeCycle {
                
                public var onLaunch: ((NZAppService, NZAppLaunchOptions) -> Void)?
                
                public var onShow: ((NZAppService, NZAppShowOptions) -> Void)?
                
                public var onHide: ((NZAppService) -> Void)?
            }
            
            public let lifeCycle = LifeCycle()
        }
        
        public let openAPI = OpenAPI()
        
        public let app = App()
        
        init() {
            
        }
    }
}

extension NZEngineConfig {
    
    public struct DevConfig {
        
        public var useDevJSSDK = false
        
        public var useDevServer = false

        init() {
            
        }
    }
}
