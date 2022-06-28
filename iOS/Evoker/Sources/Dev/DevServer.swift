//
//  DevServer.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Telegraph
import Zip



public class DevServer: WebSocket {
    
    struct AppUpdateOptions: Decodable {
        let appId: String
        var files: [String]
        let version: String
        var launchOptions: LaunchOptions?
        
        struct LaunchOptions: Decodable {
            let page: String
        }
    }
    
    public static let shared = DevServer()
    
    private let lock = Lock()
    
    private var needUpdateApps: [String: AppUpdateOptions] = [:]
    
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
    
    public override func connect(host: String = "127.0.0.1", port: UInt16 = 8800) {
        guard Engine.shared.config.dev.useDevServer else { return }
        super.connect(host: host, port: port)
    }
}

private extension DevServer {
    
    func checkVersion(_ body: Data) {
        guard let message = body.toDict(),
              let appId = message["appId"] as? String else { return }
        let version = VersionManager.shared.localAppVersion(appId: appId, envVersion: .develop)
        if let msg = ["event": "version", "data": ["version": version]].toJSONString() {
            send(msg)
        }
    }
    
    func update(_ body: Data) {
        guard let options: AppUpdateOptions = body.toModel() else { return }
        VersionManager.shared.setLocalAppVersion(appId: options.appId,
                                                   envVersion: .develop,
                                                   version: options.version)
        lock.lock()
        needUpdateApps[options.appId] = options
        lock.unlock()
    }
    
    func recvFile(_ body: Data, header: [String]) {
        guard header.count >= 2 else { return }
        
        let appId = header[0]
        let package = header[1]
        
        lock.lock()
        defer { lock.unlock() }
        guard var options = needUpdateApps[appId] else { return }
        
        var packageURL: URL
        if package == "sdk" {
            packageURL = FilePath.jsSDK(version: "dev")
        } else if package == "app" {
            packageURL = FilePath.appDist(appId: appId, envVersion: .develop)
        } else {
            return
        }

        do {
            let (_, filePath) =  FilePath.generateTmpEVFilePath(ext: "zip")
            try FilePath.createDirectory(at: filePath.deletingLastPathComponent())
            
            if FileManager.default.createFile(atPath: filePath.path, contents: body, attributes: nil) {
                try FilePath.createDirectory(at: packageURL)
                try Zip.unzipFile(filePath, destination: packageURL, overwrite: true, password: nil, progress: nil)
                
                if let index = options.files.firstIndex(of: package) {
                    options.files.remove(at: index)
                    needUpdateApps[appId] = options
                }
                
                if options.files.isEmpty {
                    DispatchQueue.main.async {
                        NotifyType.success("DEV_RELOAD").show()
                        self.needUpdateApps[appId] = nil
                        var info: [String: Any] = ["appId": appId]
                        if let launchOptions = options.launchOptions {
                            info["launchOptions"] = launchOptions
                        }
                        NotificationCenter.default.post(name: DevServer.didUpdateNotification, object: info)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                NotifyType.fail(error.localizedDescription).show()
            }
        }
    }
}

public extension DevServer {
    
    static let didUpdateNotification = Notification.Name("EvokerDevServerDidUpdateNotification")
}
