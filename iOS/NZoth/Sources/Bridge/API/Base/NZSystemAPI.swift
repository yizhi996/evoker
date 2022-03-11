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
    
    override public required init() {
        super.init()
    }
    
    public func getWindowInfo() -> [String: Any] {
        let safeArea = Constant.safeAreaInsets
        return [
            "pixelRatio": Constant.scale,
            "screenWidth": Constant.screenWidth,
            "screenHeight": Constant.screenHeight,
            "windowWidth": Constant.windowWidth,
            "windowHeight": Constant.windowHeight,
            "statusBarHeight": Constant.statusBarHeight,
            "screenTop": Constant.statusBarHeight,
            "safeArea": [
                "top": safeArea.top,
                "left": safeArea.left,
                "right": safeArea.right,
                "bottom": safeArea.bottom,
                "width": 0,
                "height": 0
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
