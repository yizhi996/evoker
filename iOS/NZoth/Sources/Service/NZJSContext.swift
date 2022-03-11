//
//  NZJSContext.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

public class NZJSContext {
    
    public var invokeHandler: (([String: Any]) -> Void)?
    public var publishHandler: (([String: Any]) -> Void)?
    
    public var name: String = "NZoth - preload - app service" {
        didSet {
            context?.name = name
        }
    }
    
    private var context: JSContext!
    
    private let nativeSDK = NZAppServiceNativeSDK()
    
    private let jsThread = DispatchQueue(label: "com.nozthdev.javascript.thread", qos: .userInteractive)
    
    private var isLoading = true
    
    private var pendingFunctions: [() -> Any?] = []
    
    public init() {
        nativeSDK.messageChannel.invokeHandler.recvMessage = { [weak self] message in
            self?.invokeHandler?(message)
        }
        
        nativeSDK.messageChannel.publishHandler.recvMessage = { [weak self] message in
            self?.publishHandler?(message)
        }
        
        jsThread.async { [unowned self] in
            let jsvm = JSVirtualMachine()
            self.context = JSContext(virtualMachine: jsvm)
            self.context.name = self.name
            self.loadSDK()
        }
    }
    
    deinit {
        clearAllTimer()
    }
    
    func clearAllTimer() {
        nativeSDK.timer.clearAll()
    }
    
    public func binding(_ object: JSExport, name: String) {
        runAfterLoad { [weak self] in
            self?.context.setObject(object, forKeyedSubscript: name as (NSCopying & NSObjectProtocol)?)
        }
    }
    
    private func runAfterLoad(_ block: @escaping () -> Void) {
        if isLoading {
            pendingFunctions.append(block)
        } else {
            jsThread.async(execute: block)
        }
    }
    
    private func loadSDK() {
        context.setObject(nativeSDK, forKeyedSubscript: "__NZAppServiceNativeSDK" as (NSCopying & NSObjectProtocol)?)
        
        let disableEval = """
        global = globalThis;
        eval = void 0;
        """
        context.evaluateScript(disableEval)
        
        let version = NZVersionManager.shared.localJSSDKVersion
        let jsSDKDir = FilePath.jsSDK(version: version)
        var vueFilename = "vue.runtime.global.prod.js"
        if NZEngine.shared.config.devServer.useDevJSSDK {
            vueFilename = "vue.runtime.global.js"
        }
        loadSDKFile(url: jsSDKDir.appendingPathComponent(vueFilename), name: "Vue.js")
        loadSDKFile(url: jsSDKDir.appendingPathComponent("nzoth.global.js"), name: "NZoth.js")
        
        isLoading = false
        pendingFunctions.forEach { _ = $0() }
        pendingFunctions = []
    }
    
    private func loadSDKFile(url: URL, name: String) {
        if let js = try? String(contentsOfFile: url.path) {
            context.evaluateScript(js, withSourceURL: URL(string: "file://sdk/\(name)"))
        } else {
            NZLogger.error("load js SDK failed, file: \(url.path) not exist")
        }
    }
}

extension NZJSContext: NZJSContainer {
    
    public func evaluateScript(_ script: String) {
        runAfterLoad { [weak self] in
            self?.context.evaluateScript(script)
        }
    }
    
    public func evaluateScript(_ script: String, name: String) {
        runAfterLoad { [weak self] in
            self?.context.evaluateScript(script, withSourceURL: URL(string: "file://usr/\(name)"))
        }
    }
    
}
