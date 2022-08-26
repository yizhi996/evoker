//
//  NativeTimer.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc protocol TimerExport: JSExport {
    
    init()

    func setTimeout(_ callback: JSValue, _ ms: Double) -> Int

    func clearTimeout(_ identifier: Int)

    func setInterval(_ callback: JSValue,_ ms: Double) -> Int

    func clearInterval(_ identifier: Int)
}

@objc class NativeTimer: NSObject, TimerExport {
    
    var id = 0
    var timers: [Int: DispatchSourceTimer] = [:]
    
    override required init() {
        super.init()
    }
    
    func setTimeout(_ callback: JSValue, _ ms: Double) -> Int {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }
    
    func clearTimeout(_ identifier: Int) {
        clear(identifier)
    }
    
    func setInterval(_ callback: JSValue,_ ms: Double) -> Int {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }
    
    func clearInterval(_ identifier: Int) {
        clear(identifier)
    }
    
    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> Int {
        var ms = ms
        if ms.isNaN {
            ms = 0
        }
        let timeInterval = DispatchTimeInterval.milliseconds(Int(ms))
        id += 1
        let tid = id
        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        if repeats {
            timer.setEventHandler {
                callback.call(withArguments: [])
            }
            timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        } else {
            timer.setEventHandler { [unowned self] in
                callback.call(withArguments: [])
                self.clear(tid)
            }
            timer.schedule(deadline: .now() + timeInterval)
        }
        timers[tid] = timer
        timer.resume()
        return tid
    }
    
    func clear(_ identifier: Int) {
        guard let timer = timers[identifier] else { return }
        timer.cancel()
        timers[identifier] = nil
    }
      
    func clearAll() {
        timers.forEach { $1.cancel() }
        timers.removeAll()
    }
}
