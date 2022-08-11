//
//  JavaScriptGenerator.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

struct JavaScriptGenerator {
    
    static func injectCSS(path: String) -> String {
        let script =
        """
        var head = document.head || document.getElementsByTagName("head");
        var link = document.createElement("link");
        link.rel="stylesheet";
        link.type="text/css";
        link.href="\(path)";
        head.appendChild(link);
        """
        return script
    }
    
    static func injectScript(path: String) -> String {
        let script =
        """
        var head = document.head || document.getElementsByTagName("head");
        var script = document.createElement("script");
        script.type = "text/javascript";
        script.src = "\(path)";
        head.appendChild(script);
        """
        return script
    }
    
    static func setAppInfo(appInfo: AppInfo) -> String {
        let script =
        """
        globalThis.__Config.appName = "\(appInfo.appName)";
        globalThis.__Config.appIcon = "\(appInfo.appIconURL)";
        globalThis.__Config.userInfo = \(appInfo.userInfo.toJSONString() ?? "{}");
        """
        return script
    }
    
    enum Env: String {
        case service
        case webview
    }
    
    static func defineConfig(appConfig: AppConfig) -> String {
        let script = "Object.assign(globalThis.__Config, \(appConfig.toJSONString() ?? "{}"));"
        return script
    }
    
    static func defineEnv(env: Env) -> String {
        let script =
        """
        globalThis.__Config = {
            platform: "\(Constant.platfrom)",
            env: "\(env.rawValue)"
        };
        """
        return script
    }
}
