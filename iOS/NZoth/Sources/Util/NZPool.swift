//
//  NZPool.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZPool<T> {
    
    private lazy var queue: [T] = []
    
    private var generate: () -> T
    
    private let autoGenerateWithEmpty: Bool
    
    public var count: Int {
        return queue.count
    }
    
    init(autoGenerateWithEmpty: Bool, _ generate: @escaping () -> T) {
        self.autoGenerateWithEmpty = autoGenerateWithEmpty
        self.generate = generate
    }
    
    func idle() -> T {
        defer {
            if autoGenerateWithEmpty && queue.isEmpty {
                queue.append(generate())
            }
        }
        if let object = queue.popLast() {
            return object
        } else {
            let object = generate()
            return object
        }
    }
    
    func push(_ object: T) {
        queue.append(object)
    }
    
    func clean(_ exec: ((T) -> Void)? = nil) {
        if let exec = exec {
            queue.forEach(exec)
        }
        queue = []
    }
}
