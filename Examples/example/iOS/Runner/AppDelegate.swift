//
//  AppDelegate.swift
//  Runner
//
//  Created by yizhi996 on 2022/3/3.
//

import UIKit
import NZoth
import Bugly
import AMapFoundationKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Bugly.start(withAppId: "c175518c9c")
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: LaunchpadViewController())
        
        DispatchQueue.main.async {
            self.launchNZothEngine()
        }

        return true
    }
    
    func launchNZothEngine() {
        if let userId = UserDefaults.standard.string(forKey: "K_UID") {
            NZEngine.shared.userId = userId
        } else {
            var userId = UUID().uuidString
            userId = String(userId[userId.startIndex..<userId.index(userId.startIndex, offsetBy: 8)]).lowercased()
            NZEngine.shared.userId = userId
            UserDefaults.standard.set(userId, forKey: "K_UID")
        }
        
        let config = NZEngineConfig.shared
        
        config.hooks.app.getAppInfo = { appId, envVersion, completionHandler in
            if let app = LaunchpadViewController.apps.first(where: { $0.appId == appId }) {
                completionHandler(NZAppInfo(appName: app.appName, appIconURL: app.appIcon), nil)
            } else {
                completionHandler(nil, NZError.custom("appId is invalid"))
            }
        }
        
        config.hooks.app.checkAppUpdate = { appId, envVersion, appVersion, nzVersion, completionHandler in
            completionHandler(true)
        }
        
        config.hooks.openAPI.login = { _, bridge, args in
            bridge.invokeCallbackSuccess(args: args, result: ["code": "abcd..."])
        }
        
        config.hooks.openAPI.checkSession = { _, bridge, args in
            bridge.invokeCallbackSuccess(args: args)
        }
        
        config.hooks.openAPI.getUserProfile = { _, bridge, args in
            let userInfo: [String: Any] = ["nickName": "yizhi996",
                                           "avatarUrl": "https://file.lilithvue.com/lilith-test-assets/avatar-new.png"]
            bridge.invokeCallbackSuccess(args: args, result: ["userInfo": userInfo])
        }
        
        config.hooks.openAPI.getUserInfo = { _, bridge, args in
            let userInfo: [String: Any] = ["nickName": "yizhi007",
                                           "avatarUrl": "https://file.lilithvue.com/lilith-test-assets/avatar-new.png"]
            bridge.invokeCallbackSuccess(args: args, result: ["userInfo": userInfo])
        }
        
        config.dev.useDevJSSDK = true
        config.dev.useDevServer = true
        NZDevServer.shared.connect(host: "192.168.0.105")
        
        NZVersionManager.shared.updateJSSDK { _ in
            NZEngine.shared.preload()
        }
        
        AMapServices.shared().apiKey = "35130e0c213883fba57defc0d2004c79"
        NZEngine.shared.injectModule(NZMapModule.self)
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}
