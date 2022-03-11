//
//  Lock.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

protocol Lockable {
    func lock()
    func unlock()
    func sync<R>(execute work: () throws -> R) rethrows -> R
}

final class Lock: Lockable {
    
    private var mutex = pthread_mutex_t()
    
    init() {
        let result = pthread_mutex_init(&mutex, nil)
        precondition(result == 0, "Failed to initialize mutex with error \(result).")
    }
    
    deinit {
        let result = pthread_mutex_destroy(&mutex)
        precondition(result == 0, "Failed to destroy mutex with error \(result).")
    }
    
    func lock() {
        let result = pthread_mutex_lock(&mutex)
        precondition(result == 0, "Failed to lock \(self) with error \(result).")
    }
    
    func unlock() {
        let result = pthread_mutex_unlock(&mutex)
        precondition(result == 0, "Failed to unlock \(self) with error \(result).")
    }
    
    func sync<R>(execute work: () throws -> R) rethrows -> R {
        lock()
        defer { unlock() }
        return try work()
    }
}
