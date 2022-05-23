//
//  NZSystemAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore
import CoreLocation

@objc public protocol NZSystemAPIExport: JSExport {
    
    init()
    
    func getWindowInfo() -> [String: Any]
    
    func getSystemSetting() -> [String: Any]
    
    func getDeviceInfo() -> [String: Any]
    
    func getAppBaseInfo() -> [String: Any]
}

@objc public class NZSystemAPI: NSObject, NZSystemAPIExport {
    
    var appId = ""
    
    var envVersion = NZAppEnvVersion.develop
    
    override public required init() {
        super.init()
    }
    
    public func getWindowInfo() -> [String: Any] {
        let screenWidth = Constant.screenWidth
        let screenHeight = Constant.screenHeight
        var windowWidth = screenWidth
        var windowHeight = screenHeight
        var screenTop = Constant.statusBarHeight + Constant.navigationBarHeight
        if let appService = NZEngine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let webPage = (appService.currentPage as! NZWebPage)
            let webView = webPage.webView
            windowWidth = webView.frame.width
            windowHeight = webView.frame.height
            screenTop = webView.frame.minY
        }
        let safeArea = Constant.safeAreaInsets
        return [
            "pixelRatio": Constant.scale,
            "screenWidth": screenWidth,
            "screenHeight": screenHeight,
            "windowWidth": windowWidth,
            "windowHeight": windowHeight,
            "statusBarHeight": Constant.statusBarHeight,
            "screenTop": screenTop,
            "safeArea": [
                "top": safeArea.top,
                "left": safeArea.left,
                "right": screenWidth - safeArea.right,
                "bottom": screenHeight - safeArea.bottom,
                "width": screenWidth - safeArea.left - safeArea.right,
                "height": screenHeight - safeArea.top - safeArea.bottom
            ]
        ]
    }
    
    public func getSystemSetting() -> [String: Any] {
        let bluetoothEnabled = PrivacyPermission.bluetooth == .authorized
        return [
            "bluetoothEnabled": bluetoothEnabled,
            "locationEnabled": CLLocationManager.locationServicesEnabled(),
            "wifiEnabled": Network.isWiFiOn(),
            "deviceOrientation": UIDevice.current.orientation.isPortrait ? "portrait" : "landscape"
        ]
    }
    
    public func getDeviceInfo() -> [String: Any] {
        return [
            "brand": Constant.brand,
            "model": Constant.modle,
            "system": Constant.system,
            "platform": Constant.platfrom
        ]
    }
    
    public func getAppBaseInfo() -> [String: Any] {
        var theme = "light"
        if #available(iOS 12.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .light {
                theme = "light"
            } else if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                theme = "dark"
            }
        }
        return [
            "SDKVersion": NZVersionManager.shared.localJSSDKVersion,
            "enableDebug": NZEngine.shared.config.devServer.useDevServer,
            "language": Locale.preferredLanguages.first!,
            "version": Constant.version,
            "hostVersion": Constant.hostVersion,
            "theme": theme
        ]
    }
}
