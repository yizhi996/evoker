//
//  DevServer.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Zip

public class DevServer: WebSocket {
    
    struct AppUpdateOptions: Decodable {
        let appId: String
        var files: [String]
        let version: String
        let launchOptions: LaunchOptions?
    }
    
    public struct LaunchOptions: Decodable {
        public let page: String?
    }
    
    public struct AppInfo: Codable {
        public let appId: String
        public let version: String
        public let envVersion: AppEnvVersion
    }
    
    public struct UpdatedInfo {
        public let appId: String
        public let version: String
        public let launchOptions: LaunchOptions?
    }
    
    private var attemptCount = 0
    
    private let lock = Lock()
    
    private var updateOptions: AppUpdateOptions?
    
    private var heartTimer: Timer?
    
    private var forceDisconnect = false
    
    public init(host: String = "", port: UInt16 = 5173) {
        var ip = host
        if ip.isEmpty,
           let ipFile = Bundle.main.url(forResource: "IP", withExtension: "txt"),
           let _ip = try? String(contentsOf: ipFile).split(separator: "\n").first {
            ip = String(_ip)
        }
        if ip.isEmpty {
            ip = "127.0.0.1"
        }
        super.init(url: URL(string: "ws://\(ip):\(port)")!)
    }
    
    public override func appWillEnterForeground() {
        super.appWillEnterForeground()
        
        attemptCount = 0
        reconnect()
    }
    
    public override func onOpen() {
        Logger.debug("dev server: connected")
        
        attemptCount = 0
        
        heartTimer?.invalidate()
        heartTimer = nil
        
        heartTimer = Timer(timeInterval: 60,
                           target: self,
                           selector: #selector(self.sendHeart),
                           userInfo: nil,
                           repeats: true)
        RunLoop.main.add(heartTimer!, forMode: .common)
    }
    
    public override func onError(_ error: Error) {
        NotifyType.fail("connect dev server fail, please check network, error: \(error.localizedDescription)").show()
    }
    
    public override func onClose(_ code: Int, reason: String?) {
        Logger.debug("dev server disconnected")
        
        heartTimer?.invalidate()
        heartTimer = nil
        
        reconnect()
    }
    
    public override func onRecv(_ data: Data) {
        guard data.count > 64 else { return }
        
        let headerData = data.subdata(in: 0..<64)
        let bodyData = data.subdata(in: 64..<data.count)
        guard let headerString = String(data: headerData, encoding: .utf8)?
                .replacingOccurrences(of: "\0", with: "") else { return }
        
        switch headerString {
        case "--APPINFO--":
            setAppInfo(bodyData)
        case "--UPDATE--":
            update(bodyData)
        default:
            let header = headerString.components(separatedBy: "---")
            recvFile(bodyData, header: header)
        }
    }
    
    public func destroy() {
        forceDisconnect = true
        disconnect()
    }
    
    public override func reconnect() {
        if forceDisconnect {
            return
        }
        
        if attemptCount + 1 > 10 {
            return
        }
        
        let delay = TimeInterval(attemptCount) * 5.0
        attemptCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            super.reconnect()
        }
    }
    
    @objc
    func sendHeart() {
        try? send("ping")
    }
    
    public class func devVersionKey(appId: String) -> String {
        return "evoker:version:app:\(appId):dev"
    }
}

private extension DevServer {
    
    func setAppInfo(_ body: Data) {
        guard let appInfo: AppInfo = body.toModel() else { return }
        NotificationCenter.default.post(name: Self.setAppInfoNotification, object: self, userInfo: ["info": appInfo])
        // check server version
        let version = UserDefaults.standard.string(forKey: Self.devVersionKey(appId: appInfo.appId)) ?? ""
        if let msg = ["event": "version", "data": ["version": version]].toJSONString() {
            try? send(msg)
        }
    }
    
    func update(_ body: Data) {
        guard let options: AppUpdateOptions = body.toModel() else { return }
        UserDefaults.standard.set(options.version, forKey: Self.devVersionKey(appId: options.appId))
        updateOptions = options
    }
    
    func recvFile(_ body: Data, header: [String]) {
        guard header.count >= 3 else { return }
        
        let appId = header[0]
        let version = header[1]
        let package = header[2]
        
        guard let options = updateOptions, options.version == version else {
            return
        }
        
        var packageURL: URL
        if package == "sdk" {
            packageURL = FilePath.jsSDK(version: "dev")
        } else if package == "app" {
            packageURL = FilePath.appDist(appId: appId, envVersion: .develop, version: "dev")
        } else {
            return
        }

        do {
            let (_, filePath) =  FilePath.generateTmpEKFilePath(ext: "zip")
            try FilePath.createDirectory(at: filePath.deletingLastPathComponent())
            
            if FileManager.default.createFile(atPath: filePath.path, contents: body, attributes: nil) {
                try FilePath.createDirectory(at: packageURL)
                try Zip.unzipFile(filePath, destination: packageURL, overwrite: true, password: nil, progress: nil)
                
                lock.lock()
                if let index = updateOptions!.files.firstIndex(of: package) {
                    updateOptions!.files.remove(at: index)
                }
                lock.unlock()
                
                if updateOptions!.files.isEmpty {
                    DispatchQueue.main.async {
                        NotifyType.success("DEV_RELOAD").show()
                        let info = UpdatedInfo(appId: appId, version: version, launchOptions: options.launchOptions)
                        NotificationCenter.default.post(name: Self.didUpdateNotification,
                                                        object: self,
                                                        userInfo: ["info": info])
                        self.updateOptions = nil
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
    
    static let setAppInfoNotification = Notification.Name("EvokerDevServerSetAppInfoNotification")
    
    static let didUpdateNotification = Notification.Name("EvokerDevServerDidUpdateNotification")
    
}
