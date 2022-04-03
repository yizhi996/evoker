//
//  NZJSBridge.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import JavaScriptCore

public class NZJSBridge {
    
    public struct InvokeArgs {
        public let eventName: String
        public let paramsString: String
        public let callbackId: Int
    }

    public struct PublishArgs {
        public let eventName: String
        public let paramsString: String
        public let webViewId: Int
    }
    
    public weak var appService: NZAppService?
    
    public weak var container: NZJSContainer?
    
    public init(appService: NZAppService, container: NZJSContainer) {
        self.appService = appService
        self.container = container
    }
}

public extension NZJSBridge {
    
    func onInvoke(_ args: NZJSBridge.InvokeArgs) {
        guard let appService = appService else { return }

        NZLogger.debug("\(appService.appId) - invoke: \(args.eventName)")
        
        if let event = NZEngine.shared.extraAPIs[args.eventName] {
            event.onInvoke(args: args, bridge: self)
        } else if let event = NZEngine.shared.builtInAPIs[args.eventName] {
            event.onInvoke(args: args, bridge: self)
        } else {
            let error = NZError.bridgeFailed(reason: .eventNotDefined)
            invokeCallbackFail(args: args, error: error)
        }
    }
    
    func onPublish(_ args: NZJSBridge.PublishArgs) {
        guard let appService = appService else { return }
        
        NZLogger.debug("\(appService.appId) - publish: \(args.eventName)")
        
        switch args.eventName {
        case "vSync", "invokeAppServiceMethod", "callbackWebViewMethod", "selectorQuery":
            appService.bridge.subscribeHandler(method: NZSubscribeKey(args.eventName),
                                               data: args.paramsString,
                                               webViewId: args.webViewId)
        case "callbackAppServiceMethod", "invokeWebViewMethod":
            guard let webPage = appService.findWebPage(from: args.webViewId) else { return }
            webPage.webView.bridge.subscribeHandler(method: NZSubscribeKey(args.eventName),
                                                    data: args.paramsString,
                                                    webViewId: args.webViewId)
        default:
            break
        }
    }
}

public extension NZJSBridge {
    
    func invokeCallback(event: String, callbackId: Int, errMsg: String, data: Any?) {
        var result = ["id": callbackId,
                      "event": event,
                      "errMsg": errMsg] as [String : Any]
        result["data"] = data ?? [:]
        guard let message = result.toJSONString() else {
            NZLogger.error("invokeCallback JSON serialization failed")
            return
        }
        container?.evaluateScript("NZJSBridge.invokeCallbackHandler(\(message))")
    }
    
    func invokeCallbackSuccess(args: NZJSBridge.InvokeArgs) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: nil)
    }
    
    func invokeCallbackSuccess(args: NZJSBridge.InvokeArgs, result: [String: Any]? = nil) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: result)
    }
    
    func invokeCallbackSuccess(args: NZJSBridge.InvokeArgs, result: Encodable? = nil) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: "",
                       data: result?.toJSONString())
    }
    
    func invokeCallbackFail(args: NZJSBridge.InvokeArgs, error: NZError) {
        invokeCallback(event: args.eventName,
                       callbackId: args.callbackId,
                       errMsg: error.localizedDescription,
                       data: nil)
    }
}

public extension NZJSBridge {
    
    func subscribeHandler(method: NZSubscribeKey, data: [String: Any], webViewId: Int = 0) {
        guard let message = data.toJSONString() else { return }
        let script = "NZJSBridge.subscribeHandler('\(method.rawValue)',\(message),\(webViewId))"
        container?.evaluateScript(script)
    }
    
    func subscribeHandler(method: NZSubscribeKey, data: Encodable, webViewId: Int = 0) {
        guard let message = data.toJSONString() else { return }
        let script = "NZJSBridge.subscribeHandler('\(method.rawValue)',\(message),\(webViewId))"
        container?.evaluateScript(script)
    }
    
    /// 只能传 JSON String !!!
    func subscribeHandler(method: NZSubscribeKey, data: String, webViewId: Int = 0) {
        let script = "NZJSBridge.subscribeHandler('\(method.rawValue)',\(data),\(webViewId))"
        container?.evaluateScript(script)
    }
}

public protocol NZJSContainer: AnyObject {
    
    func evaluateScript(_ script: String)
}

public protocol NZAPI {
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge)
}

protocol NZBuiltInAPI: NZAPI, CaseIterable {
    
}

public struct NZSubscribeKey: Hashable, Equatable, RawRepresentable {
    
    public let rawValue: String

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
