//
//  Base64Object.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc protocol Base64ObjectExport: JSExport {
    
    init()
    
    func base64ToArrayBuffer(_ string: String) -> [UInt8]
    
    func arrayBufferToBase64(_ buffer: [UInt8]) -> String
    
}

@objc class Base64Object: NSObject, Base64ObjectExport {
    
    override required init() {
        super.init()
    }
    
    func base64ToArrayBuffer(_ string: String) -> [UInt8] {
        let data = Data(base64Encoded: string)
        return data?.bytes ?? []
    }
    
    func arrayBufferToBase64(_ buffer: [UInt8]) -> String {
        return buffer.toBase64()
    }
}
