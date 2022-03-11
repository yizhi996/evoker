//
//  Queue.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class Queue {
    
    static let concurrentQueueGroup = ConcurrentQueueGroup(name: "com.nozthdev.async-draw-queue", qos: .userInteractive)
}

class ConcurrentQueueGroup {
    
    private var queues: [DispatchQueue] = []
    
    private let name: String
    
    private let maxConcurrentCount: Int32
    
    private let qos: DispatchQoS
    
    private var counter: Int32 = 0
    
    public init(name: String = UUID().uuidString,
                maxConcurrentCount: Int = ProcessInfo.processInfo.activeProcessorCount,
                qos: DispatchQoS = .default) {
        
        self.name = name
        self.maxConcurrentCount = Int32(maxConcurrentCount)
        self.qos = qos
        
        for _ in 0..<maxConcurrentCount {
            let queue = DispatchQueue(label: name, qos: qos)
            queues.append(queue)
        }
    }
    
    public func idleQueue() -> DispatchQueue {
        OSAtomicIncrement32(&counter)
        let i = Int(counter % maxConcurrentCount)
        return queues[i]
    }
}

struct DebouncerSemaphore {
    
    private let semaphore: DispatchSemaphore
    
    init(value: Int) {
        semaphore = DispatchSemaphore(value: value)
    }
    
    func sync(execute: () -> Void) {
        defer { semaphore.signal() }
        semaphore.wait()
        execute()
    }
}

class Throttler {
    
    private let queue: DispatchQueue
    private let interval: TimeInterval
    private let semaphore: DebouncerSemaphore
    private var workItem: DispatchWorkItem?
    private var lastExecuteTime = Date()
    
    init(seconds: TimeInterval, qos: DispatchQoS = .default) {
        interval = seconds
        semaphore = DebouncerSemaphore(value: 1)
        queue = DispatchQueue(label: "throttler.queue", qos: qos)
    }
    
    func invoke(_ action: @escaping (() -> Void)) {
        semaphore.sync {
            workItem?.cancel()
            workItem = DispatchWorkItem(block: { [weak self] in
                self?.lastExecuteTime = Date()
                DispatchQueue.main.async {
                    action()
                }
            })
            let deadline = Date().timeIntervalSince(lastExecuteTime) > interval ? 0 : interval
            if let item = workItem {
                queue.asyncAfter(deadline: .now() + deadline, execute: item)
            }
        }
    }
}
