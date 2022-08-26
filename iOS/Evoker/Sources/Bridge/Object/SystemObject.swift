//
//  SystemObject.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore
import CoreLocation

@objc protocol SystemObjectExport: JSExport {
    
    init()
    
    func getWindowInfo() -> [String: Any]
    
    func getSystemSetting() -> [String: Any]
    
    func getDeviceInfo() -> [String: Any]
    
    func getAppBaseInfo() -> [String: Any]
    
    func getAppAuthorizeSetting() -> [String: Any]
}

@objc class SystemObject: NSObject, SystemObjectExport {
    
    var appId = ""
    
    var envVersion = AppEnvVersion.develop
    
    override required init() {
        super.init()
    }
    
    func getWindowInfo() -> [String: Any] {
        let screenWidth = Constant.screenWidth
        let screenHeight = Constant.screenHeight
        var windowWidth = screenWidth
        var windowHeight = screenHeight
        var screenTop = Constant.statusBarHeight + Constant.navigationBarHeight
        if let appService = Engine.shared.getAppService(appId: appId, envVersion: envVersion) {
            let webPage = (appService.currentPage as! WebPage)
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
    
    func getSystemSetting() -> [String: Any] {
        let bluetoothEnabled = PrivacyPermission.bluetooth == .authorized
        return [
            "bluetoothEnabled": bluetoothEnabled,
            "locationEnabled": CLLocationManager.locationServicesEnabled(),
            "wifiEnabled": Network.isWiFiOn(),
            "deviceOrientation": UIDevice.current.orientation.isPortrait ? "portrait" : "landscape"
        ]
    }
    
    func getDeviceInfo() -> [String: Any] {
        return [
            "brand": Constant.brand,
            "model": Constant.modle,
            "system": Constant.system,
            "platform": Constant.platfrom
        ]
    }
    
    func getAppBaseInfo() -> [String: Any] {
        var theme = "light"
        if #available(iOS 12.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .light {
                theme = "light"
            } else if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                theme = "dark"
            }
        }
        return [
            "SDKVersion": PackageManager.shared.localJSSDKVersion,
            "enableDebug": false,
            "language": Locale.preferredLanguages.first!,
            "version": Constant.hostVersion,
            "nativeSDKVersion": Constant.nativeSDKVersion,
            "theme": theme
        ]
    }
    
    func getAppAuthorizeSetting() -> [String: Any] {
        let notificationAuthorized = PrivacyPermission.notificationSettings
        return [
            "albumAuthorized": PrivacyPermission.album.toString(),
            "bluetoothAuthorized": PrivacyPermission.bluetooth.toString(),
            "cameraAuthorized": PrivacyPermission.camera.toString(),
            "locationAuthorized": PrivacyPermission.location.toString(),
            "locationReducedAccuracy": PrivacyPermission.isLocationReduced,
            "microphoneAuthorized": PrivacyPermission.microphone.toString(),
            "notificationAuthorized": notificationAuthorized.status.toString(),
            "notificationAlertAuthorized": notificationAuthorized.alert.toString(),
            "notificationBadgeAuthorized": notificationAuthorized.badge.toString(),
            "notificationSoundAuthorized": notificationAuthorized.sound.toString(),
        ]
    }
}
