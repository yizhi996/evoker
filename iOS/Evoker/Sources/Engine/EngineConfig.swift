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
        
        /// App 钩子
        public let app = App()
                
        /// App 生命周期钩子
        public let appLifeCycle = AppLifeCycle()
        
        /// Page 生命周期钩子
        public let pageLifeCycle = PageLifeCycle()

        /// 定义 OpenAPI
        public let openAPI = OpenAPI()
        
    }
}

extension EngineConfig.Hooks {
    
    public class App {
        
        public typealias GetAppInfoCompletionHandler = (AppInfo?, EVError?) -> Void
        
        /// App 在启动时需要获取 App Info
        public var getAppInfo: ((String, AppEnvVersion, GetAppInfoCompletionHandler) -> Void)?
        
        /// App 在首次启动时检查释放需要更新
        public var checkAppUpdate: ((String, AppEnvVersion, String, String, BoolBlock) -> Void)?
        
        /// 自定义点击胶囊的更多按钮时显示的 action
        /// - returns:
        /// 第一个数组是第一行，第二个数组是第二行，第三个 Bool 表示是否在第二行的最前面加入内置的 action（包含设置和重启）
        public var fetchAppMoreActionSheetItems: ((AppService) -> ([AppMoreAction], [AppMoreAction], Bool))?
        
        /// 点击自定义的 AppMoreAction 时执行，可根据 key 判断需要执行的事件
        public var clickAppMoreAction: ((AppService, AppMoreAction) -> Void)?
        
    }

}

extension EngineConfig.Hooks {
    
    public class AppLifeCycle {
        
        /// 应用首次冷启动时触发
        public var onLaunch: ((AppService, AppLaunchOptions) -> Void)?
        
        /// 应用首次冷启动或者从后台进入前台时触发
        public var onShow: ((AppService, AppShowOptions) -> Void)?
        
        /// 应用返回后台时触发
        public var onHide: ((AppService) -> Void)?

    }
    
    public class PageLifeCycle {
        
        /// 页面首次加载时触发
        public var onLoad: ((Page) -> Void)?
        
        /// 页面首次加载、者页面显示时或者应用从后台进去前台时触发
        public var onShow: ((Page) -> Void)?
        
        /// 页面第一次渲染完成时触发
        public var onReady: ((Page) -> Void)?
        
        /// 页面隐藏时触发或者应用进入后台时触发
        public var onHide: ((Page) -> Void)?
        
        /// 页面被销毁时触发
        public var onUnload: ((Page) -> Void)?
    }

}

extension EngineConfig.Hooks {
    
    public class OpenAPI {
        
        public typealias Callback = (AppService, JSBridge, JSBridge.InvokeArgs) -> (Void)
        
        public var login: Callback?
        
        public var checkSession: Callback?
        
        public var getUserInfo: Callback?
        
        public var getUserProfile: Callback?
        
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
