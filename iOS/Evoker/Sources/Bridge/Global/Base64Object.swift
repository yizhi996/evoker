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
    
    func base64ToArrayBuffer(_ string: String) -> JSValue?
    
    func arrayBufferToBase64(_ buffer: JSValue) -> String
    
}

@objc class Base64Object: NSObject, Base64ObjectExport {
    
    weak var context: JavaScriptCore.JSContext?
    
    override required init() {
        super.init()
    }
    
    func base64ToArrayBuffer(_ string: String) -> JSValue? {
        guard let data = Data(base64Encoded: string) else { return nil }
        return data.toJSArrayBuffer(context: context!)
    }
    
    func arrayBufferToBase64(_ buffer: JSValue) -> String {
        guard let bytes = buffer.toArrayBuffer() else {
            return ""
        }
        let data = Data(bytes: bytes, count: buffer.getArrayBufferLength())
        return data.base64EncodedString()
    }
}
