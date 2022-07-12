//
//  PackageManager.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Alamofire
import Zip

public class PackageManager {
    
    public static let shared = PackageManager()
    
    private let jsSDKVersionkey = "evoker:version:js-sdk"
    
    public var localJSSDKVersion: String {
        if Engine.shared.config.dev.useDevJSSDK {
            return "dev"
        }
        let version = Constant.nativeSDKVersion
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
    
    init() {
        Zip.addCustomFileExtension("evpkg")
    }
    
    func setLocalJSSDKVersion(_ version: String) {
        UserDefaults.standard.set(version, forKey: jsSDKVersionkey)
    }

    public func localAppVersion(appId: String, envVersion: AppEnvVersion) -> String {
        return UserDefaults.standard.string(forKey: "evoker:version:app:\(appId):\(envVersion)") ?? ""
    }
    
    public func setLocalAppVersion(appId: String, envVersion: AppEnvVersion, version: String) {
        UserDefaults.standard.set(version, forKey: "evoker:version:app:\(appId):\(envVersion)")
    }
    
    public func updateJSSDK(resultHandler handler: @escaping BoolBlock) {
        if Engine.shared.config.dev.useDevJSSDK {
            handler(false)
        } else {
            // TODO
            handler(false)
        }
    }
    
    public func unpackBudleSDK() throws {
        let version = Constant.nativeSDKVersion
        let filePath = Constant.assetsBundle.url(forResource: "evoker-sdk", withExtension: "evpkg")!
        try unpackLocalSDK(filePath: filePath, version: version)
    }
    
    public func unpackLocalSDK(filePath: URL, version: String) throws {
        let dest = FilePath.jsSDK(version: version)
        
        if checkPackIntegrity(filePath: dest) {
            return
        }
        
        try unpack(src: filePath, dest: dest)
    }
    
    public func unpackAppService(appId: String, envVersion: AppEnvVersion, filePath: URL) throws {
        let dest = FilePath.appDist(appId: appId, envVersion: envVersion)
        try unpack(src: filePath, dest: dest)
    }
    
    func unpack(src: URL, dest: URL) throws {
        try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true, attributes: nil)
        try Zip.unzipFile(src, destination: dest, overwrite: true, password: nil)
        if !checkPackIntegrity(filePath: dest) {
            throw EKError.packNotIntegrity(dest.path)
        }
    }
    
    public func checkPackIntegrity(filePath: URL) -> Bool {
        guard let string = try? String(contentsOf: filePath.appendingPathComponent("files")) else { return false }
        let files = string.split(separator: "\n")
        var exists = false
        for file in files {
            exists = FileManager.default.fileExists(atPath: filePath.appendingPathComponent(String(file)).path)
            if !exists {
                return exists
            }
        }
        return exists
    }
    
}
