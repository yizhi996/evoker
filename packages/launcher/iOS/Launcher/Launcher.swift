//
//  Launcher.swift
//  Launcher
//

import Foundation
import Evoker
import AMapFoundationKit

class Launcher {
    
    struct App: Decodable {
        let url: String
        let appId: String
        let name: String?
        let icon: String?
        let desc: String?
        let version: String
        let envVersion: AppEnvVersion
    }
    
    static let launcherAppId = "com.evokerdev.launcher"
    
    static let shared = Launcher()
    
    var devServer: DevServer?
    
    lazy var devServers: [String: DevServer] = [:]
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupEvoker() {
        setupUserId()
        
        let config = Engine.shared.config
        config.hooks.app.getAppInfo = { appId, envVersion, completionHandler in
            var appInfo = AppInfo(appName: appId, appIconURL: "")
            if appId == Self.launcherAppId {
                appInfo.appName = "Launcher"
            } else if let app = self.findApp(appId: appId, envVersion: envVersion) {
                appInfo.appName = app.name ?? app.appId
                appInfo.appIconURL = app.icon ?? ""
            }
            completionHandler(appInfo)
        }
        
        config.hooks.app.shareAppMessage = { appService, content in
            NotifyType.success("Not implementation.").show()
        }
        
        config.hooks.app.allowHideCapsule = { appService in
            return appService.appId == Self.launcherAppId
        }
        
        LauncherAPI.allCases.forEach { Engine.shared.registAPI($0.rawValue, api: $0) }
        
        AMapServices.shared().apiKey = "35130e0c213883fba57defc0d2004c79"
        Engine.shared.injectModule(MapModule.self)
        
        Engine.shared.preload()
        
        if let pkgURL = Bundle.main.url(forResource: "app-service", withExtension: "evpkg") {
            do {
                let version = "1.0.0"
                try PackageManager.shared.unpackAppService(appId: Self.launcherAppId,
                                                           envVersion: .release,
                                                           version: version,
                                                           filePath: pkgURL)
                PackageManager.shared.setLocalAppVersion(appId: Self.launcherAppId, envVersion: .release, version: version)
                Engine.shared.openApp(appId: Self.launcherAppId, method: .redirect)
            } catch {
                NotifyType.fail("\(error.localizedDescription)").show()
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setAppInfo(_:)),
                                               name: DevServer.setAppInfoNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAppVersion(_:)),
                                               name: DevServer.didUpdateNotification,
                                               object: nil)
    }
    
    @objc
    func setAppInfo(_ notification: Notification) {
        guard let devServer = notification.object as? DevServer,
              let info = notification.userInfo?["info"] as? DevServer.AppInfo else { return }
        
        guard let appService = fetchLauncherAppService() else { return }
        
        var data = info.dictionary ?? [:]
        if let url = devServers.first(where: { $0.value === devServer })?.key {
            data["url"] = url
        }
        
        appService.bridge.subscribeHandler(method: Self.setAppInfoSubscribeKey, data: data)
    }
    
    @objc
    func updateAppVersion(_ notification: Notification) {
        guard let info = notification.userInfo?["info"] as? DevServer.UpdatedInfo else { return }
        
        guard let appService = fetchLauncherAppService() else { return }
        appService.bridge.subscribeHandler(method: Self.updateAppVersionSubscribeKey,
                                           data: ["appId": info.appId,
                                                  "envVersion": AppEnvVersion.develop.rawValue,
                                                  "version": info.version])
    }
    
    func setupUserId() {
        let key = "evoker:uid"
        if let userId = UserDefaults.standard.string(forKey: key) {
            Engine.shared.userId = userId
        } else {
            var userId = UUID().uuidString
            userId = String(userId[userId.startIndex..<userId.index(userId.startIndex, offsetBy: 8)]).lowercased()
            Engine.shared.userId = userId
            UserDefaults.standard.set(userId, forKey: key)
        }
    }
    
    func getLocalIPAddress() -> String {
        var ip = "0.0.0.0"
        if let ipFile = Bundle.main.url(forResource: "IP", withExtension: "txt"),
           let _ip = try! String(contentsOf: ipFile).split(separator: "\n").first {
            ip = String(_ip)
        }
        return ip
    }
    
    func fetchLauncherAppService() -> AppService? {
        return Engine.shared.getAppService(appId: Self.launcherAppId, envVersion: .release)
    }
    
    func findApp(appId: String, envVersion: AppEnvVersion) -> App? {
        guard let launcher = fetchLauncherAppService() else {
            return nil
        }
        
        let (res, _) = launcher.storage.get(key: "k_apps")
        if let (dataString, _) = res,
           let apps: [App] = dataString.toModel() {
           return apps.first(where: { $0.appId == appId && $0.envVersion == envVersion })
        }
        return nil
    }
}

extension Launcher {
    
    static let setAppInfoSubscribeKey = SubscribeKey("LAUNCHER_DEV_SERVER_SET_APP_INFO")
    
    static let updateAppVersionSubscribeKey = SubscribeKey("LAUNCHER_DEV_SERVER_UPDATE_APP_VERSION")

}
