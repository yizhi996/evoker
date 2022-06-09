//
//  NZVersionManager.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Alamofire

public class NZVersionManager {
    
    public static let shared = NZVersionManager()
    
    private let jsSDKVersionkey = "nzoth:version:js-sdk"
    
    public var localJSSDKVersion: String {
        if NZEngineConfig.shared.dev.useDevJSSDK {
            return "dev"
        }
        let version = Constant.jsSDKVersion
        if let currentVersion = UserDefaults.standard.string(forKey: jsSDKVersionkey), !version.isEmpty {
            let orderd = version.compare(currentVersion, options: .numeric)
            if orderd == .orderedDescending {
                UserDefaults.standard.set(version, forKey: jsSDKVersionkey)
                return version
            }
            return currentVersion
        }
        UserDefaults.standard.set(version, forKey: jsSDKVersionkey)
        return version
    }
    
    func setLocalJSSDKVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: jsSDKVersionkey)
    }

    public func localAppVersion(appId: String, envVersion: NZAppEnvVersion) -> String {
        return UserDefaults.standard.string(forKey: "nzoth:version:app:\(appId):\(envVersion)") ?? ""
    }
    
    public func setLocalAppVersion(appId: String, envVersion: NZAppEnvVersion, version: String) {
        UserDefaults.standard.set(version, forKey: "nzoth:version:app:\(appId):\(envVersion)")
    }
    
    public func updateJSSDK(resultHandler handler: @escaping NZBoolBlock) {
        if NZEngineConfig.shared.dev.useDevJSSDK {
            handler(false)
        } else {
            handler(false)
        }
    }

}
