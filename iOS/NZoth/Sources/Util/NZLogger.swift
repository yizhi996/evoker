//
//  NZLogger.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss:SSS"
    return dateFormatter
}()

class NZLogger {
    
    enum Level: Int {
        case debug
        case info
        case warn
        case error
        
        func toString() -> String {
            switch self {
            case .debug:
                return "debug"
            case .info:
                return "info"
            case .warn:
                return "warn"
            case .error:
                return "error"
            }
        }
    }
    
    enum From: String {
        case host
        case sdk
        case app
    }
    
    class func log(_ level: Level, message: String, from: From = .host) {
        let date = dateFormatter.string(from: Date())
        let log = "[NZoth]|\(level.toString())|\(date)|\(from)|\(message)"
        NZEngine.shared.reportLog(log)
    }
    
    class func debug(_ message: String, from: From = .host) {
        log(.debug, message: message, from: from)
    }
    
    class func info(_ message: String, from: From = .host) {
        log(.info, message: message, from: from)
    }
    
    class func warn(_ message: String, from: From = .host) {
        log(.warn, message: message, from: from)
    }
    
    class func error(_ message: String, from: From = .host) {
        log(.error, message: message, from: from)
    }
}
