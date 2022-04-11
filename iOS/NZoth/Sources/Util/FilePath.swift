//
//  FilePath.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import UIKit

public struct FilePath {
    
    static func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory,
                                           in: .userDomainMask).first!.appendingPathComponent("com.nozthdev")
    }
    
    static func documentDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask).first!.appendingPathComponent("com.nozthdev")
    }
    
    static func tmpDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.nozthdev")
    }
        
    static func mainDatabase() -> URL {
        return documentDirectory().appendingPathComponent("database/nzoth.db")
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
    
    typealias NZFile = String
    
    /// Document/com.nzothdev/sandbox/{userId}
    static func sandbox(userId: String) -> URL {
        return documentDirectory().appendingPathComponent("sandbox").appendingPathComponent(userId)
    }
    
    /// Document/com.nzothdev/sandbox/{userId}/{appId}/usr
    static func usr(appId: String, userId: String) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("usr")
    }
    
    /// Document/com.nzothdev/sandbox/{userId}/{appId}/usr/{path}
    static func usr(appId: String, userId: String, path: String) -> URL {
        return usr(appId: appId, userId: userId).appendingPathComponent(path)
    }
    
    /// Document/com.nzothdev/sandbox/{userId}/{appId}/store
    static func store(appId: String, userId: String) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("store")
    }
    
    /// Document/com.nzothdev/sandbox/{userId}/{appId}/store/{filename}
    static func store(appId: String, userId: String, filename: String) -> URL {
        return store(appId: appId, userId: userId).appendingPathComponent(filename)
    }
    
    /// tmp/com.nzothdev/{filename}
    static func tmp(filename: String) -> URL {
        return tmpDirectory().appendingPathComponent(filename)
    }
    
    /// Document/com.nzothdev/sandbox/{userId}/{appId}/db/storage.db
    static func storageDatabase(appId: String, userId: String) -> URL {
        return sandbox(userId: userId)
            .appendingPathComponent(appId)
            .appendingPathComponent("db")
            .appendingPathComponent("storage.db")
    }
    
    static func generateStoreNZFilePath(appId: String, userId: String, ext: String) -> (NZFile, URL) {
        let id = UUID().uuidString.md5()
        let filename = "store_\(id).\(ext)"
        return ("nzfile://\(filename)", FilePath.store(appId: appId, userId: userId, filename: filename))
    }
    
    static func generateTmpNZFilePath(ext: String) -> (NZFile, URL) {
        let id = UUID().uuidString.md5()
        let filename = "tmp_\(id).\(ext)"
        return ("nzfile://\(filename)", FilePath.tmp(filename: filename))
    }
    
    static func nzFilePathToRealFilePath(appId: String, userId: String, filePath: String) -> URL? {
        let scheme = "nzfile://"
        let usr = scheme + "usr"
        let store = scheme + "store_"
        let tmp = scheme + "tmp_"
        if filePath.hasPrefix(usr) {
            let start = filePath.index(filePath.startIndex, offsetBy: usr.count)
            let path = filePath[start..<filePath.endIndex]
            return FilePath.usr(appId: appId, userId: userId, path: String(path))
        } else if filePath.hasPrefix(store) {
            let start = filePath.index(filePath.startIndex, offsetBy: scheme.count)
            let filename = filePath[start..<filePath.endIndex]
            return FilePath.store(appId: appId, userId: userId, filename: String(filename))
        } else if filePath.hasPrefix(tmp) {
            let start = filePath.index(filePath.startIndex, offsetBy: scheme.count)
            let filename = filePath[start..<filePath.endIndex]
            return FilePath.tmp(filename: String(filename))
        }
        return nil
    }
    
}

extension FilePath {
    
    /// Document/com.nzothdev/sdk/{version}
    public static func jsSDK(version: String) -> URL {
        return documentDirectory().appendingPathComponent("sdk/\(version)")
    }
    
    /// Document/com.nzothdev/app/
    public static func appRootDirectory() -> URL {
        return documentDirectory().appendingPathComponent("app")
    }
    /// Document/com.nzothdev/app/{appId}/
    public static func app(appId: String) -> URL {
        return appRootDirectory().appendingPathComponent("\(appId)")
    }
    
    /// Document/com.nzothdev/app/{appId}/packages/{envVersion}/{version}.nzpkg
    public static func appPackage(appId: String, envVersion: NZAppEnvVersion, version: String) -> URL {
        return app(appId: appId).appendingPathComponent("packages/\(envVersion)/\(version).nzpkg")
    }
    /// Document/com.nzothdev/app/{appId}/dist/{envVersion}/
    public static func appDist(appId: String, envVersion: NZAppEnvVersion) -> URL {
        return app(appId: appId).appendingPathComponent("dist/\(envVersion)/")
    }
    /// Document/com.nzothdev/app/{appId}/dist/{envVersion}/index.html
    public static func appIndexHTMLPath(appId: String, envVersion: NZAppEnvVersion) -> URL {
        return appDist(appId: appId, envVersion: envVersion).appendingPathComponent("index.html")
    }
    /// Document/com.nzothdev/app/{appId}/dist/{envVersion}/{src}
    public static func appStaticFilePath(appId: String, envVersion: NZAppEnvVersion, src: String) -> URL {
        var path = src
        if path.starts(with: "/src") {
            let end = path.index(path.startIndex, offsetBy: 4)
            path.replaceSubrange(path.startIndex..<end, with: "")
        }
        return appDist(appId: appId, envVersion: envVersion).appendingPathComponent(path)
    }
}
