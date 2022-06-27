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
import Zip

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
        try? unpackBudleSDK()
        if NZEngineConfig.shared.dev.useDevJSSDK {
            handler(false)
        } else {
            handler(false)
        }
    }
    
    func unpackBudleSDK() throws {
        let version = Constant.jsSDKVersion
        let filePath = Constant.assetsBundle.url(forResource: "nzoth-sdk", withExtension: "nzpkg")!
        try unpackLocalSDK(filePath: filePath, version: version)
    }
    
    func unpackLocalSDK(filePath: URL, version: String) throws {
        Zip.addCustomFileExtension("nzpkg")
        
        let dest = FilePath.jsSDK(version: version)
        
        if FileManager.default.fileExists(atPath: dest.appendingPathComponent("index.html").path) {
            return
        }
        
        try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true, attributes: nil)
        try Zip.unzipFile(filePath, destination: dest, overwrite: true, password: nil)
    }

}
