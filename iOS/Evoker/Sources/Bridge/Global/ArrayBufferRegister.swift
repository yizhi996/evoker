//
//  ArrayBufferRegister.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc protocol ArrayBufferRegisterExport: JSExport {
    
    init()
    
    func get(_ id: Int) -> JSValue?
    
    func set(_ arrayBuffer: JSValue) -> Int
}

@objc class ArrayBufferRegister: NSObject, ArrayBufferRegisterExport {
    
    static let Key = "__arrayBuffer__"
    
    var incNumber = 1
    
    lazy var buffers: [Int: JSValue] = [:]
    
    weak var context: JavaScriptCore.JSContext?

    override required init() {
        super.init()
    }
    
    func get(_ id: Int) -> JSValue? {
        if let arrayBuffer = buffers[id] {
            buffers[id] = nil
            return arrayBuffer
        }
        return nil
    }
    
    func set(_ arrayBuffer: JSValue) -> Int {
        let id = incNumber
        buffers[id] = arrayBuffer
        incNumber += 1
        return id
    }
    
    func clearAll() {
        buffers = [:]
    }
}
