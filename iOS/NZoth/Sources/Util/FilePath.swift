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
    
    static func tempDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.nozthdev")
    }
    
    static func nzFileDirectory() -> URL {
        return tempDirectory().appendingPathComponent("nzfile")
    }
    
    static func nzFilePathToRealFilePath(appId: String, filePath: String) -> URL? {
        let scheme = "nzfile://"
        if filePath.hasPrefix(scheme) {
            let usr = scheme + "usr/"
            if filePath.hasPrefix(usr) {
                let start = filePath.index(filePath.startIndex, offsetBy: usr.count)
                let path = filePath[start..<filePath.endIndex]
                return FilePath.createUserNZFilePath(appId: appId, path: String(path))
            } else {
                let start = filePath.index(filePath.startIndex, offsetBy: scheme.count)
                let fileName = filePath[start..<filePath.endIndex]
                return FilePath.nzFileDirectory().appendingPathComponent(String(fileName))
            }
        }
        return nil
    }
    
    static func filePathToNZFilePath(url: URL) -> String {
        return "nzfile://" + url.lastPathComponent
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
        try? FileManager.default.removeItem(at: tempDirectory())
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
    
    static func createTempNZFilePath(ext: String) -> (URL, NZFile) {
        let id = UUID().uuidString.md5()
        let fileName = "temp_\(id).\(ext)"
        return (nzFileDirectory().appendingPathComponent(fileName), "nzfile://\(fileName)")
    }
    
    static func createUserNZFilePath(appId: String, path: String) -> URL {
        return app(appId: appId).appendingPathComponent("file").appendingPathComponent(path)
    }
    
    static func networkLog() -> URL {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let day = fmt.string(from: Date())
        return FilePath.cacheDirectory().appendingPathComponent("log/net/net-\(day).log")
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
    /// Document/com.nzothdev/app/{appId}/database/{envVersion}/storage.db
    public static func appStorage(appId: String, envVersion: NZAppEnvVersion) -> URL {
        return app(appId: appId).appendingPathComponent("database/\(envVersion)/storage.db")
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
