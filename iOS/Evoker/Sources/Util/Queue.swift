//
//  Queue.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class KeepActiveThread: NSObject {
    
    private var thread: Thread!
    
    private var runLoop: RunLoop?
    
    private var port: Port?
    
    private var isStop = false
    
    override init() {
        super.init()
        
        thread = Thread(target: self, selector: #selector(run), object: nil)
        thread.start()
    }
    
    @objc
    private func run() {
        runLoop = RunLoop.current
        port = NSMachPort()
        runLoop!.add(port!, forMode: .default)
        while !isStop {
            runLoop!.run(mode: .default, before: .distantFuture)
        }
    }
    
    func stop() {
        if let runLoop = runLoop, let port = port {
            runLoop.remove(port, forMode: .default)
            CFRunLoopStop(runLoop.getCFRunLoop())
        }
        isStop = true
        runLoop = nil
        port = nil
    }
    
    func async(execute work: @escaping @convention(block) () -> Void) {
        perform(#selector(_exec(execute:)), on: thread, with: work, waitUntilDone: false)
    }
    
    @objc
    private func _exec(execute work: @escaping @convention(block) () -> Void) {
        work()
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
