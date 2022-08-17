//
//  WebSocketModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class WebSocketModule: NSObject, Module {
    
    typealias SocketTaskId = Int
    
    static var name: String {
        return "com.evokerdev.module.ws"
    }
    
    static var apis: [String : API] {
        var apis: [String: API] = [:]
        WebSocketAPI.allCases.forEach { apis[$0.rawValue] = $0 }
        return apis
    }
  
    weak var appService: AppService?
    
    lazy var webSockets = [SocketTaskId: WebSocket]()
    
    required init(appService: AppService) {
        super.init()
        self.appService = appService
    }
    
    func onExit(_ service: AppService) {
        webSockets.forEach { _, ws in
            ws.disconnect()
        }
    }
    
}

extension WebSocketModule: WebSocketTaskDelegate {
    
    func webSocketOnOpen(_ webSocket: WebSocketTask) {
        appService?.bridge.subscribeHandler(method: Self.onOpenSubscribeKey, data: ["socketTaskId": webSocket.socketTaskId])
    }
    
    func webSocket(_ webSocket: WebSocketTask, onClose code: Int, reason: String?) {
        appService?.bridge.subscribeHandler(method: Self.onCloseSubscribeKey,
                                            data: ["socketTaskId": webSocket.socketTaskId,
                                                   "code": code,
                                                   "reason": reason ?? ""])
    }
    
    func webSocket(_ webSocket: WebSocketTask, onError error: Error) {
        appService?.bridge.subscribeHandler(method: Self.onErrorSubscribeKey,
                                            data: ["socketTaskId": webSocket.socketTaskId,
                                                   "errMsg": error.localizedDescription])
    }
    
    func webSocket(_ webSocket: WebSocketTask, onMessage message: Any) {
        appService?.bridge.subscribeHandler(method: Self.onMessageSubscribeKey,
                                            data: ["socketTaskId": webSocket.socketTaskId, "data": message])
    }
    
}

extension WebSocketModule {
    
    static let onOpenSubscribeKey = SubscribeKey("MODULE_WEB_SOCKET_ON_OPEN")
    
    static let onCloseSubscribeKey = SubscribeKey("MODULE_WEB_SOCKET_ON_CLOSE")
    
    static let onErrorSubscribeKey = SubscribeKey("MODULE_WEB_SOCKET_ON_ERROR")
    
    static let onMessageSubscribeKey = SubscribeKey("MODULE_WEB_SOCKET_ON_MESSAGE")
}
