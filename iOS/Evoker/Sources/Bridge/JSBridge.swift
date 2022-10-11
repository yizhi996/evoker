//
//  JSBridge.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import JavaScriptCore

public protocol JSBridgeArgs {
    var eventName: String { get }
    var paramsString: String { get }
}

public class JSBridge {
    
    public struct InvokeArgs: JSBridgeArgs {
        public let eventName: String
        public let paramsString: String
        public let callbackId: Int
    }

    public struct PublishArgs: JSBridgeArgs {
        public let eventName: String
        public let paramsString: String
        public let webViewId: Int
    }
    
    public weak var appService: AppService?
    
    public weak var container: JSContainer?
    
    public init(appService: AppService, container: JSContainer) {
        self.appService = appService
        self.container = container
    }
}

public extension JSBridge {
    
    func onInvoke(_ args: JSBridge.InvokeArgs) {
        guard let appService = appService else { return }

        Logger.debug("\(appService.appId) - invoke: \(args.eventName)")
        
        if let event = Engine.shared.extraAPIs[args.eventName] {
            event.onInvoke(appService: appService, bridge: self, args: args)
        } else if let event = Engine.shared.builtInAPIs[args.eventName] {
            event.onInvoke(appService: appService, bridge: self, args: args)
        } else {
            let error = EKError.bridgeFailed(reason: .eventNotDefined)
            invokeCallbackFail(args: args, error: error)
        }
    }
    
    func onPublish(_ args: JSBridge.PublishArgs) {
        guard let appService = appService else { return }
        
        Logger.debug("\(appService.appId) - publish: \(args.eventName)")
        
        switch args.eventName {
        case "vdSync", "invokeAppServiceMethod", "callbackWebViewMethod":
            appService.bridge.subscribeHandler(method: SubscribeKey(args.eventName),
                                               data: args.paramsString,
                                               webViewId: args.webViewId)
        case "callbackAppServiceMethod", "invokeWebViewMethod":
            guard let webPage = appService.findWebPage(from: args.webViewId) else { return }
            webPage.webView.bridge.subscribeHandler(method: SubscribeKey(args.eventName),
                                                    data: args.paramsString,
                                                    webViewId: args.webViewId)
        default:
            break
        }
    }
}

public extension JSBridge {
    
    func invokeCallback(event: String, callbackId: Int, errMsg: String, data: Any?) {
        var result = ["id": callbackId,
                      "event": event,
                      "errMsg": errMsg] as [String : Any]
        result["data"] = data ?? [:]
        guard let message = result.toJSONString() else {
            Logger.error("invokeCallback JSON serialization failed")
            return
        }
        container?.evaluateScript("JSBridge.invokeCallbackHandler(\(message))")
    }
    
    func invokeCallbackSuccess(args: JSBridge.InvokeArgs) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: nil)
    }
    
    func invokeCallbackSuccess(args: JSBridge.InvokeArgs, result: [String: Any]? = nil) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: result)
    }
    
    func invokeCallbackSuccess(args: JSBridge.InvokeArgs, result: Encodable? = nil) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: result?.toJSONString())
    }
    
    func invokeCallbackFail(args: JSBridge.InvokeArgs, error: EKError) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: error.localizedDescription,
                       data: nil)
    }
}

public extension JSBridge {
    
    func subscribeHandler(method: SubscribeKey, data: [String: Any], webViewId: Int = 0) {
        guard let message = data.toJSONString() else { return }
        let script = "JSBridge.subscribeHandler('\(method.rawValue)',\(message),\(webViewId))"
        container?.evaluateScript(script)
    }
    
    func subscribeHandler(method: SubscribeKey, data: Encodable, webViewId: Int = 0) {
        guard let message = data.toJSONString() else { return }
        let script = "JSBridge.subscribeHandler('\(method.rawValue)',\(message),\(webViewId))"
        container?.evaluateScript(script)
    }
    
    /// 只能传 JSON String !!!
    func subscribeHandler(method: SubscribeKey, data: String, webViewId: Int = 0) {
        let script = "JSBridge.subscribeHandler('\(method.rawValue)',\(data),\(webViewId))"
        container?.evaluateScript(script)
    }
}

public protocol JSContainer: AnyObject {
    
    func evaluateScript(_ script: String)
}

public protocol API {
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs)
}

protocol CaseIterableAPI: API, CaseIterable {
    
}

public struct SubscribeKey: Hashable, Equatable, RawRepresentable {
    
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
