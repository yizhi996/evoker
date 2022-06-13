//
//  NZBase64API.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol NZBase64APIExport: JSExport {
    
    init()
    
    func base64ToArrayBuffer(_ string: String) -> [UInt8]
    
    func arrayBufferToBase64(_ buffer: [UInt8]) -> String
    
}

@objc public class NZBase64API: NSObject, NZBase64APIExport {
    
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
