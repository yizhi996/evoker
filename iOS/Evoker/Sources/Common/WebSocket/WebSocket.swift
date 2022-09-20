//
//  WebSocket.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import SocketRocket
import Alamofire

public class WebSocket: NSObject {
    
    public private(set) var isForeground = true
    
    private var request: URLRequest?
    
    private var protocols: [String]?
    
    private var client: SRWebSocket?
    
    public var readyState: SRReadyState {
        return client?.readyState ?? .CONNECTING
    }
    
    public init(url: URL, headers: [String: String] = [:], protocols: [String]? = nil, timeout: TimeInterval = 0) {
        super.init()
        
        self.protocols = protocols
        
        var request = URLRequest(url: url)
        request.method = .get
        request.timeoutInterval = timeout
        request.headers = HTTPHeaders(headers)
        self.request = request
        
        let client = SRWebSocket(urlRequest: request, protocols: protocols)
        client.delegate = self
        self.client = client
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func connect() {
        guard isForeground else { return }
        if readyState != .CONNECTING {
            reconnect()
        } else {
            client?.open()
        }
    }
    
    public func disconnect(code: Int = 1000, reason: String? = nil) {
        client?.close(withCode: code, reason: reason)
    }
    
    public func reconnect() {
        client = nil
        
        if let request = request {
            let client = SRWebSocket(urlRequest: request, protocols: protocols)
            client.delegate = self
            self.client = client
            connect()
        }
    }
    
    @objc
    public func appWillEnterForeground() {
        isForeground = true
    }
    
    @objc
    public func appDidEnterBackground() {
        isForeground = false
        disconnect()
    }
    
    public func onOpen() {
        
    }
    
    public func onClose(_ code: Int, reason: String?) {
        
    }
    
    public func onError(_ error: Error) {
        
    }
    
    public func onRecv(_ data: Data) {
        
    }
    
    public func onRecv(_ text: String) {
        
    }
    
    public func send(_ text: String) throws {
        try client?.send(string: text)
    }
    
    public func send(_ data: Data) throws {
        try client?.send(data: data)
    }
}

extension WebSocket: SRWebSocketDelegate {
    
    public func webSocketDidOpen(_ webSocket: SRWebSocket) {
        onOpen()
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        onClose(code, reason: reason)
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
        onError(error)
    }
    
    public func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        if let message = message as? String {
            onRecv(message)
        } else {
            onRecv(message as! Data)
        }
    }
}
