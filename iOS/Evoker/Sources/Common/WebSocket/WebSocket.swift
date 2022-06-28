//
//  WebSocket.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Telegraph

public class WebSocket {
    
    public private(set) var host: String = "127.0.0.1"
    
    public private(set) var port: UInt16 = 8800
    
    public private(set) var isForeground = true
    
    public private(set) var isConnected = false
    
    private var heartTimer: Timer?
    
    private var client: WebSocketClient?
    
    private var attemptCount = 0
    
    public init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChange),
                                               name: Engine.networkStatusDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public func connect(host: String, port: UInt16) {
        self.host = host
        self.port = port
        
        guard isForeground && Engine.shared.networkType != .none else { return }
        
        let address = "ws://\(host):\(port)"
        do {
            client?.delegate = nil
            client?.disconnect()
            client = try WebSocketClient(address)
            client?.delegate = self
        } catch {
            Logger.error("dev server connect failed: \(error)")
        }
        client?.connect()
    }
    
    public func disconnect() {
        client?.disconnect()
    }
    
    private func reconnect() {
        if attemptCount + 1 > 10 {
            return
        }
        
        let delay = TimeInterval(attemptCount) * 5.0
        attemptCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.connect(host: self.host, port: self.port)
        }
    }
    
    @objc private func appWillEnterForeground() {
        isForeground = true
        connect(host: host, port: port)
    }
    
    @objc private func appDidEnterBackground() {
        isForeground = false
        disconnect()
    }
    
    @objc private func networkStatusChange() {
        connect(host: host, port: port)
    }
    
    @objc private func sendHeart() {
        client?.send(text: "ping")
    }
    
    func onRecv(_ data: Data) {
        
    }
    
    func onRecv(_ text: String) {
        
    }
    
    func send(_ text: String) {
        client?.send(text: text)
    }
    
    func send(_ data: Data) {
        client?.send(data: data)
    }
}

extension WebSocket: WebSocketClientDelegate {
    
    public func webSocketClient(_ client: WebSocketClient, didConnectToHost host: String) {
        Logger.debug("dev server: \(host) connected")
        
        isConnected = true
        
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
    
    public func webSocketClient(_ client: WebSocketClient, didDisconnectWithError error: Error?) {
        Logger.debug("dev server disconnected")
        
        isConnected = false
        
        heartTimer?.invalidate()
        heartTimer = nil
        
        reconnect()
    }
    
    public func webSocketClient(_ client: WebSocketClient, didReceiveText text: String) {
        onRecv(text)
    }
    
    public func webSocketClient(_ client: WebSocketClient, didReceiveData data: Data) {
        onRecv(data)
    }
    
}
