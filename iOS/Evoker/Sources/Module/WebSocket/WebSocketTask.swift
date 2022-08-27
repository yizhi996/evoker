//
//  WebSocketTask.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class WebSocketTask: WebSocket {
    
    var socketTaskId: Int = 0
    
    weak var delegate: WebSocketTaskDelegate?
    
    override init(url: URL, headers: [String : String] = [:], protocols: [String]? = nil, timeout: TimeInterval = 0) {
        super.init(url: url, headers: headers, protocols: protocols, timeout: timeout)
    }
    
    override func onOpen() {
        super.onOpen()
        
        delegate?.webSocketOnOpen(self)
    }
    
    override func onClose(_ code: Int, reason: String?) {
        super.onClose(code, reason: reason)
        
        delegate?.webSocket(self, onClose: code, reason: reason)
        
        if let module = delegate as? WebSocketModule {
            module.webSockets[socketTaskId] = nil
        }
    }
    
    override func onError(_ error: Error) {
        super.onError(error)
        
        delegate?.webSocket(self, onError: error)
        
        if let module = delegate as? WebSocketModule {
            module.webSockets[socketTaskId] = nil
        }
    }
    
    override func onRecv(_ text: String) {
        super.onRecv(text)
        
        delegate?.webSocket(self, onMessage: text)
    }
    
    override func onRecv(_ data: Data) {
        super.onRecv(data)
        
        delegate?.webSocket(self, onMessage: data)
    }
}

protocol WebSocketTaskDelegate: NSObject {
    
    func webSocketOnOpen(_ webSocket: WebSocketTask)
    
    func webSocket(_ webSocket: WebSocketTask, onClose code: Int, reason: String?)
    
    func webSocket(_ webSocket: WebSocketTask, onError error: Error)
    
    func webSocket(_ webSocket: WebSocketTask, onMessage message: String)
    
    func webSocket(_ webSocket: WebSocketTask, onMessage message: Data)
    
}
