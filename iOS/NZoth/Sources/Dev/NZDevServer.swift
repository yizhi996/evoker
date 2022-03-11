//
//  NZDevServer.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Telegraph
import Zip

public struct NZDevServerConfig {
    
    public var useDevJSSDK: Bool = false
    
    public var useDevServer = false
    
    public var host: String = "127.0.0.1"
    
    public var port: UInt16 = 8800
    
}

class NZDevServer: NZWebSocket {
    
    public static let shared = NZDevServer()
    
    private let lock = Lock()
    
    private var needUploadFiles: Set<String> = []
    
    override func onRecv(_ data: Data) {
        guard data.count > 64 else { return }
        
        let headerData = data.subdata(in: 0..<64)
        let bodyData = data.subdata(in: 64..<data.count)
        guard let headerString = String(data: headerData, encoding: .utf8)?
                .replacingOccurrences(of: "\0", with: "") else { return }
        
        switch headerString {
        case "--CHECKVERSION--":
            checkVersion(bodyData)
        case "--UPDATE--":
            update(bodyData)
        default:
            let header = headerString.components(separatedBy: "---")
            recvFile(bodyData, header: header)
        }
    }

}

private extension NZDevServer {
    
    func checkVersion(_ body: Data) {
        guard let message = body.toDict(),
              let appId = message["appId"] as? String else { return }
        let version = NZVersionManager.shared.localAppVersion(appId: appId, envVersion: .develop)
        if let msg = ["event": "version", "data": ["version": version]].toJSONString() {
            send(msg)
        }
    }
    
    func update(_ body: Data) {
        guard let message = body.toDict(),
              let appId = message["appId"] as? String,
              let version = message["version"] as? String,
              let files = message["files"] as? [String] else { return }
        NZVersionManager.shared.setLocalAppVersion(appId: appId, envVersion: .develop, version: version)
        lock.lock()
        files.forEach { needUploadFiles.insert("\(appId)_\($0)") }
        lock.unlock()
    }
    
    func recvFile(_ body: Data, header: [String]) {
        guard header.count >= 2 else { return }
        
        let appId = header[0]
        let package = header[1]
        
        lock.lock()
        let contains = needUploadFiles.contains("\(appId)_\(package)")
        lock.unlock()
        if !contains {
            return
        }
        
        var packageURL: URL
        if package == "sdk" {
            packageURL = FilePath.jsSDK(version: "dev")
        } else if package == "app" {
            packageURL = FilePath.appDist(appId: appId, envVersion: .develop)
        } else {
            return
        }
        
        do {
            let (filePath, _) =  FilePath.createTempNZFilePath(ext: "zip")
            try FilePath.createDirectory(at: filePath.deletingLastPathComponent())
            
            if FileManager.default.createFile(atPath: filePath.path, contents: body, attributes: nil) {
                try FilePath.createDirectory(at: packageURL)
                try Zip.unzipFile(filePath, destination: packageURL, overwrite: true, password: nil, progress: nil)
                lock.lock()
                if let i = needUploadFiles.firstIndex(of: "\(appId)_\(package)") {
                    needUploadFiles.remove(at: i)
                }
                let finished = needUploadFiles.filter { $0.starts(with: "\(appId)_") }.isEmpty
                lock.unlock()
                if finished {
                    DispatchQueue.main.async {
                        NZNotifyType.success("DEV_RELOAD").show()
                        NotificationCenter.default.post(name: NZDevServer.didUpdateNotification, object: appId)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                NZNotifyType.fail(error.localizedDescription).show()
            }
        }
    }
}

extension NZDevServer {
    
    static let didUpdateNotification = Notification.Name("NZothDevServerDidUpdateNotification")
}
