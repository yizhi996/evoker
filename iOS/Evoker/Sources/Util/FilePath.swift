//
//  FilePath.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import UIKit

public struct FilePath {
    
    static func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory,
                                           in: .userDomainMask).first!.appendingPathComponent("com.evokerdev")
    }
    
    static func documentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask).first!.appendingPathComponent("com.evokerdev")
    }
    
    static func tmpDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.evokerdev")
    }
        
    static func mainDatabase() -> URL {
        return documentDirectory().appendingPathComponent("database/evoker.db")
    }
    
    static func createDirectory(at url: URL) throws {
        if !FileManager.default.fileExists(atPath: url.path, isDirectory: nil) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
}

public extension FilePath {
    
    static func cleanTemp() {
        try? FileManager.default.removeItem(at: tmpDirectory())
    }
}

extension FilePath {
    
    public static func fileExists(_ path: URL) -> Bool {
        return FileManager.default.fileExists(atPath: path.path)
    }
    
    public static func fileExists(_ path: String?) -> Bool {
        guard let path = path else { return false }
        return FileManager.default.fileExists(atPath: path)
    }
}

public extension FilePath {
    
    typealias EKFile = String
    
    /// Document/com.evokerdev/sandbox/{userId}
    static func sandbox(userId: String = Engine.shared.userId) -> URL {
        return documentDirectory().appendingPathComponent("sandbox").appendingPathComponent(userId)
    }
    
    /// Document/com.evokerdev/sandbox/{userId}/{appId}/usr
    static func usr(appId: String, userId: String = Engine.shared.userId) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("usr")
    }
    
    /// Document/com.evokerdev/sandbox/{userId}/{appId}/usr/{path}
    static func usr(appId: String, userId: String = Engine.shared.userId, path: String) -> URL {
        return usr(appId: appId, userId: userId).appendingPathComponent(path)
    }
    
    /// Document/com.evokerdev/sandbox/{userId}/{appId}/store
    static func store(appId: String, userId: String = Engine.shared.userId) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("store")
    }
    
    /// Document/com.evokerdev/sandbox/{userId}/{appId}/store/{filename}
    static func store(appId: String, userId: String = Engine.shared.userId, filename: String) -> URL {
        return store(appId: appId, userId: userId).appendingPathComponent(filename)
    }
    
    /// tmp/com.evokerdev/{filename}
    static func tmp(filename: String) -> URL {
        return tmpDirectory().appendingPathComponent(filename)
    }
    
    /// Document/com.evokerdev/sandbox/{userId}/{appId}/db/storage.db
    static func storageDatabase(appId: String, userId: String = Engine.shared.userId) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("db")
            .appendingPathComponent("storage.db")
    }
    
    static func generateStoreEKFilePath(appId: String, userId: String = Engine.shared.userId, ext: String) -> (EKFile, URL) {
        let id = UUID().uuidString.md5()
        let filename = "\(id).\(ext)"
        return generateStoreEKFilePath(appId: appId, userId: userId, filename: filename)
    }
    
    static func generateStoreEKFilePath(appId: String, userId: String = Engine.shared.userId, filename: String) -> (EKFile, URL) {
        return ("ekfile://store_\(filename)", FilePath.store(appId: appId, userId: userId, filename: filename))
    }
    
    static func generateTmpEKFilePath(ext: String) -> (EKFile, URL) {
        let id = UUID().uuidString.md5()
        let filename = "\(id).\(ext)"
        return ("ekfile://tmp_\(filename)", FilePath.tmp(filename: filename))
    }
    
    static func isEKFile(filePath: String) -> Bool {
        return filePath.starts(with: "ekfile://")
    }
    
    static func ekFilePathToRealFilePath(appId: String, userId: String = Engine.shared.userId, filePath: String) -> URL? {
        let scheme = "ekfile://"
        let usr = scheme + "usr"
        let store = scheme + "store_"
        let tmp = scheme + "tmp_"
        if filePath.hasPrefix(usr) {
            let start = filePath.index(filePath.startIndex, offsetBy: usr.count + (filePath.hasPrefix(usr + "/") ? 1 : 0))
            let path = filePath[start..<filePath.endIndex]
            return FilePath.usr(appId: appId, userId: userId, path: String(path))
        } else if filePath.hasPrefix(store) {
            let start = filePath.index(filePath.startIndex, offsetBy: store.count)
            let filename = filePath[start..<filePath.endIndex]
            return FilePath.store(appId: appId, userId: userId, filename: String(filename))
        } else if filePath.hasPrefix(tmp) {
            let start = filePath.index(filePath.startIndex, offsetBy: tmp.count)
            let filename = filePath[start..<filePath.endIndex]
            return FilePath.tmp(filename: String(filename))
        }
        return nil
    }
    
}

extension FilePath {
    
    /// Document/com.evokerdev/sdk/{version}
    public static func jsSDK(version: String) -> URL {
        return documentDirectory().appendingPathComponent("sdk/\(version)")
    }
    
    /// Document/com.evokerdev/app/
    public static func appRootDirectory() -> URL {
        return documentDirectory().appendingPathComponent("app")
    }
    
    /// Document/com.evokerdev/app/{appId}/
    public static func app(appId: String) -> URL {
        return appRootDirectory().appendingPathComponent("\(appId)")
    }
    
    /// Document/com.evokerdev/app/{appId}/packages/{envVersion}/{version}.evpkg
    public static func appPackage(appId: String, envVersion: AppEnvVersion, version: String) -> URL {
        return app(appId: appId).appendingPathComponent("packages/\(envVersion)/\(version).evpkg")
    }
    
    /// Document/com.evokerdev/app/{appId}/dist/{envVersion}/
    public static func appDist(appId: String, envVersion: AppEnvVersion) -> URL {
        return app(appId: appId).appendingPathComponent("dist/\(envVersion)/")
    }
    
    /// Document/com.evokerdev/app/{appId}/dist/{envVersion}/{src}
    public static func appStaticFilePath(appId: String, envVersion: AppEnvVersion, src: String) -> URL {
        var path = src
        if path.starts(with: "/src") {
            let end = path.index(path.startIndex, offsetBy: 4)
            path.replaceSubrange(path.startIndex..<end, with: "")
        }
        return appDist(appId: appId, envVersion: envVersion).appendingPathComponent(path)
    }
}
