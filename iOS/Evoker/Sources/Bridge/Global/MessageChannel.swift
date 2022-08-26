//
//  MessageChannel.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc protocol MessageChannelPortExport: JSExport {
    
    init()
    
    func postMessage(_ message: Any)
}

@objc class MessageChannelPort: NSObject, MessageChannelPortExport {
    
    var recvMessage: (([String: Any]) -> Void)?
    
    override required init() {
        super.init()
    }
    
    func postMessage(_ message: Any) {
        guard let dict = message as? [String: Any] else { return }
        recvMessage?(dict)
    }
}

@objc protocol MessageChannelExports: JSExport {
    
    var publishHandler: MessageChannelPort { get }
    
    var invokeHandler: MessageChannelPort { get }
    
    init()
}

@objc class MessageChannel: NSObject, MessageChannelExports {
    
    var publishHandler: MessageChannelPort = MessageChannelPort()
    
    var invokeHandler: MessageChannelPort = MessageChannelPort()
        
    override required init() {
        super.init()
    }
}
