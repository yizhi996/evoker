//
//  JSContext.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

public class JSContext {
    
    public var invokeHandler: (([String: Any]) -> Void)?
    
    public var publishHandler: (([String: Any]) -> Void)?
     
    public var name: String = "Evoker - preload - app service" {
        didSet {
            context?.name = name
        }
    }
    
    internal var context: JavaScriptCore.JSContext!
    
    let nativeSDK = AppServiceNativeSDK()
    
    let nativeTimer = NativeTimer()
    
    let messageChannel = MessageChannel()
    
    let systemObject = SystemObject()
    
    let base64Object = Base64Object()
    
    let fileSystem = FileSystemManagerObject()
    
    let storageObject = StorageSyncObject()
    
    let arrayBufferRegister = ArrayBufferRegister()
    
    private let workThread = KeepActiveThread()
    
    private var isLoading = true
    
    private var pendingFunctions: [() -> Any?] = []
    
    public init() {
        messageChannel.invokeHandler.recvMessage = { [weak self] message in
            self?.invokeHandler?(message)
        }
        
        messageChannel.publishHandler.recvMessage = { [weak self] message in
            self?.publishHandler?(message)
        }
        
        workThread.async {
            self.createJSContext()
        }
    }
    
    private func createJSContext() {
        let jsvm = JSVirtualMachine()
        context = JavaScriptCore.JSContext(virtualMachine: jsvm)
        context.name = name
        context.exceptionHandler = { ctx, error in
            if let globalThis = ctx?.globalObject, let error = error {
//                globalThis.invokeMethod("invokeAppOnError", withArguments: [error])
            }
        }
        loadSDK()
    }

    func exit() {
        nativeTimer.clearAll()
        fileSystem.closeAll()
        arrayBufferRegister.clearAll()
        pendingFunctions = []
        workThread.stop()
    }
    
    public func binding(_ object: JSExport, name: String) {
        runAfterLoad { [unowned self] in
            self.context.setObject(object, forKeyedSubscript: name as (NSCopying & NSObjectProtocol)?)
        }
    }
    
    private func runAfterLoad(_ block: @escaping () -> Void) {
        if isLoading {
            pendingFunctions.append(block)
        } else {
            workThread.async(execute: block)
        }
    }
    
    private func loadSDK() {
        context.setObject(nativeSDK, forKeyedSubscript: "__NativeSDK" as (NSCopying & NSObjectProtocol)?)
        context.setObject(messageChannel, forKeyedSubscript: "__MessageChannel" as (NSCopying & NSObjectProtocol)?)
        context.setObject(nativeTimer, forKeyedSubscript: "__NativeTimer" as (NSCopying & NSObjectProtocol)?)
        context.setObject(systemObject, forKeyedSubscript: "__System" as (NSCopying & NSObjectProtocol)?)
        base64Object.context = context
        context.setObject(base64Object, forKeyedSubscript: "__Base64" as (NSCopying & NSObjectProtocol)?)
        context.setObject(fileSystem, forKeyedSubscript: "__FileSystem" as (NSCopying & NSObjectProtocol)?)
        context.setObject(storageObject, forKeyedSubscript: "__Storage" as (NSCopying & NSObjectProtocol)?)
        context.setObject(arrayBufferRegister, forKeyedSubscript: "__ArrayBufferRegister" as (NSCopying & NSObjectProtocol)?)
        
        let disableEval = "eval = void 0;"
        context.evaluateScript(disableEval + JavaScriptGenerator.defineEnv(env: .service))
        
        let version = PackageManager.shared.localJSSDKVersion
        let jsSDKDir = FilePath.jsSDK(version: version)
        let ext = Engine.shared.config.dev.useDevJSSDK ? ".js" : ".prod.js"
        loadSDKFile(url: jsSDKDir.appendingPathComponent("vue.runtime.global" + ext), name: "Vue.js")
        loadSDKFile(url: jsSDKDir.appendingPathComponent("evoker.global" + ext), name: "Evoker.js")
        
        isLoading = false
        pendingFunctions.forEach { _ = $0() }
        pendingFunctions = []
    }
    
    private func loadSDKFile(url: URL, name: String) {
        if let js = try? String(contentsOfFile: url.path) {
            context.evaluateScript(js, withSourceURL: URL(string: "file://sdk/\(name)"))
        } else {
            Logger.error("load js SDK failed, file: \(url.path) not exist")
        }
    }
}

extension JSContext: JSContainer {
    
    public func evaluateScript(_ script: String) {
        runAfterLoad { [unowned self] in
            self.context.evaluateScript(script)
        }
    }
    
    public func evaluateScript(_ script: String, name: String) {
        runAfterLoad { [unowned self] in
            self.context.evaluateScript(script, withSourceURL: URL(string: "file://usr/\(name)"))
        }
    }
    
}
