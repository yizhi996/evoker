//
//  Base64Object.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol Base64ObjectExport: JSExport {
    
    init()
    
    func base64ToArrayBuffer(_ string: String) -> [UInt8]
    
    func arrayBufferToBase64(_ buffer: [UInt8]) -> String
    
}

@objc public class Base64Object: NSObject, Base64ObjectExport {
    
    override public required init() {
        super.init()
    }
    
    public func base64ToArrayBuffer(_ string: String) -> [UInt8] {
        let data = Data(base64Encoded: string)
        return data?.bytes ?? []
    }
    
    public func arrayBufferToBase64(_ buffer: [UInt8]) -> String {
        return buffer.toBase64()
    }
}
