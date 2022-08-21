//
//  MessageChannel.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol MessageChannelPortExport: JSExport {
    
    init()
    
    func postMessage(_ message: Any)
}

@objc public class MessageChannelPort: NSObject, MessageChannelPortExport {
    
    var recvMessage: (([String: Any]) -> Void)?
    
    override public required init() {
        super.init()
    }
    
    public func postMessage(_ message: Any) {
        guard let dict = message as? [String: Any] else { return }
        recvMessage?(dict)
    }
}

@objc public protocol MessageChannelExports: JSExport {
    
    var publishHandler: MessageChannelPort { get }
    
    var invokeHandler: MessageChannelPort { get }
    
    init()
}

@objc public class MessageChannel: NSObject, MessageChannelExports {
    
    public var publishHandler: MessageChannelPort = MessageChannelPort()
    
    public var invokeHandler: MessageChannelPort = MessageChannelPort()
        
    override public required init() {
        super.init()
    }
}
