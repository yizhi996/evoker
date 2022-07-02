//
//  AppDelegate.swift
//  Runner
//
//  Created by yizhi996 on 2022/3/3.
//

import UIKit
import Evoker

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window!.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: LaunchpadViewController())
        
        DispatchQueue.main.async {
            self.launchEvokerEngine()
        }

        return true
    }
    
    func launchEvokerEngine() {
        if let userId = UserDefaults.standard.string(forKey: "K_UID") {
            Engine.shared.userId = userId
        } else {
            var userId = UUID().uuidString
            userId = String(userId[userId.startIndex..<userId.index(userId.startIndex, offsetBy: 8)]).lowercased()
            Engine.shared.userId = userId
            UserDefaults.standard.set(userId, forKey: "K_UID")
        }
        
        let config = Engine.shared.config
        
        config.hooks.app.getAppInfo = { appId, envVersion, completionHandler in
            if let app = LaunchpadViewController.apps.first(where: { $0.appId == appId }) {
                completionHandler(AppInfo(appName: app.appName, appIconURL: app.appIcon), nil)
            } else {
                completionHandler(nil, EVError.custom("appId is invalid"))
            }
        }
        
        config.dev.useDevServer = true
        DevServer.shared.connect()
        
        VersionManager.shared.updateJSSDK { _ in
            Engine.shared.preload()
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
}
