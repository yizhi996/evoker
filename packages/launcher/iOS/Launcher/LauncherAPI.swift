//
//  LauncherAPI.swift
//  Launcher
//

import Foundation
import Evoker

enum LauncherAPI: String, Evoker.API, CaseIterable {
    
    case openApp
    
    case updateApp
    
    case deleteApp
    
    case isRunning
    
    case getAppVersion
    
    case connectDevServer
    
    case disconnectDevServer
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .openApp:
                openApp(appService: appService, bridge: bridge, args: args)
            case .updateApp:
                updateApp(appService: appService, bridge: bridge, args: args)
            case .deleteApp:
                deleteApp(appService: appService, bridge: bridge, args: args)
            case .isRunning:
                isRunning(appService: appService, bridge: bridge, args: args)
            case .getAppVersion:
                getAppVersion(appService: appService, bridge: bridge, args: args)
            case .connectDevServer:
                connectDevServer(appService: appService, bridge: bridge, args: args)
            case .disconnectDevServer:
                disconnectDevServer(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func openApp(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let appId: String
            let envVersion: AppEnvVersion
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var options = AppLaunchOptions()
        options.envVersion = params.envVersion
        Engine.shared.openApp(appId: params.appId, launchOptions: options) { error in
            if let error = error {
                bridge.invokeCallbackFail(args: args, error: error)
            } else {
                bridge.invokeCallbackSuccess(args: args)
            }
        }
    }
    
    private func updateApp(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let appId: String
            let envVersion: AppEnvVersion
            let version: String
            let filePath: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let filePath = FilePath.ekFilePathToRealFilePath(appId: params.appId, filePath: params.filePath) else {
            let error = EKError.bridgeFailed(reason: .invalidFilePath(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        do {
            try PackageManager.shared.unpackAppService(appId: params.appId,
                                                       envVersion: params.envVersion,
                                                       version: params.version,
                                                       filePath: filePath)
            PackageManager.shared.setLocalAppVersion(appId: params.appId,
                                                     envVersion: params.envVersion,
                                                     version: params.version)
            bridge.invokeCallbackSuccess(args: args)
        } catch {
            let error = EKError.bridgeFailed(reason: .custom("\(error.localizedDescription)"))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func deleteApp(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let appId: String
            let envVersion: AppEnvVersion
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let appService = Engine.shared.getAppService(appId: params.appId, envVersion: params.envVersion) {
            appService.exit()
        }
        Engine.shared.clearAppData(appId: params.appId,  options: .all)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func isRunning(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let appId: String
            let envVersion: AppEnvVersion
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        bridge.invokeCallbackSuccess(args: args,
                                     result: ["running": Engine.shared.getAppService(appId: params.appId,
                                                                                     envVersion: params.envVersion) != nil])
    }
    
    private func getAppVersion(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let appId: String
            let envVersion: AppEnvVersion
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var version = PackageManager.shared.localAppVersion(appId: params.appId, envVersion: params.envVersion)
        if !PackageManager.shared.appExists(appId: params.appId, envVersion: params.envVersion, version: version) {
            version = ""
        }
        bridge.invokeCallbackSuccess(args: args, result: ["version": version])
    }
    
    private func connectDevServer(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let url: String
            let host: String
            let port: UInt16
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            bridge.invokeCallbackFail(args: args, error: EKError.bridgeFailed(reason: .jsonParseFailed))
            return
        }
        
        var host = params.host
        if params.host == "0.0.0.0" {
            host = Launcher.shared.getLocalIPAddress()
        }
        if let prev = Launcher.shared.devServers[params.url] {
            if prev.readyState != .OPEN {
                prev.connect()
            }
        } else {
            let devServer = DevServer(host: host, port: params.port)
            devServer.connect()
            Launcher.shared.devServers[params.url] = devServer
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func disconnectDevServer(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let url: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            bridge.invokeCallbackFail(args: args, error: EKError.bridgeFailed(reason: .jsonParseFailed))
            return
        }
        
        if let prev = Launcher.shared.devServers[params.url] {
            prev.destroy()
            Launcher.shared.devServers[params.url] = nil
        }
        bridge.invokeCallbackSuccess(args: args)
    }
}
