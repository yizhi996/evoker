//
//  JSValue+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

extension JSValue {
    
    func toArrayBuffer() -> UnsafeMutableRawPointer? {
        let bytes = JSObjectGetArrayBufferBytesPtr(context.jsGlobalContextRef, jsValueRef, nil)
        return bytes
    }
    
    func toData() -> Data? {
        guard let bytes = toArrayBuffer() else { return nil }
        return Data(bytes: bytes, count: getArrayBufferLength())
    }
    
    func getArrayBufferLength() -> Int {
        return JSObjectGetArrayBufferByteLength(context.jsGlobalContextRef, jsValueRef, nil)
    }
}

extension Data {
    
    func toJSArrayBuffer(context: JavaScriptCore.JSContext) -> JSValue {
        let prt = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: count)
        _ = withUnsafeBytes { prt.initialize(from: UnsafeBufferPointer(start: $0, count: count)) }
       
        let deallocator: JSTypedArrayBytesDeallocator = { ptr, _ in
            ptr?.deallocate()
        }
        
        let arrayBufferRef = JSObjectMakeArrayBufferWithBytesNoCopy(context.jsGlobalContextRef,
                                                                    prt.baseAddress,
                                                                    count,
                                                                    deallocator,
                                                                    nil,
                                                                    nil)
        return JSValue(jsValueRef: arrayBufferRef, in: context)
    }
}
