//
//  Uitls.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

extension Comparable {
    func clampe(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

class DoubleLevelDictionary<F: Hashable, S: Hashable, T> {
    
    private var dict: [F: [S: T]] = [:]
    
    func all() -> [T] {
        var res: [T] = []
        dict.values.forEach { $0.values.forEach { res.append($0) } }
        return res
    }
    
    func get(_ first: F) -> [S: T]? {
        return dict[first]
    }
    
    func get(_ first: F, _ second: S) -> T? {
        guard let l = dict[first], let r = l[second] else { return nil }
        return r
    }
    
    func set(_ first: F, _ second: S, value: T) {
        if dict[first] != nil {
            dict[first]![second] = value
        } else {
            dict[first] = [second: value]
        }
    }
    func remove(_ first: F) {
        dict[first] = [:]
    }
    
    func remove(_ first: F, _ second: S) {
        dict[first]?[second] = nil
    }
    
    func removeAll() {
        dict = [:]
    }
    
}

class PerformanceTimer {
    
    static let shared = PerformanceTimer()
    
    var labals: [String: TimeInterval] = [:]
    
    func start(_ label: String) {
        labals[label] = Date().timeIntervalSince1970
    }
    
    func end(_ label: String) {
        if let x = labals[label] {
            let now = Date().timeIntervalSince1970
            print("🔔 \(label) now: \(now * 1000) use: \((now - x) * 1000) ms")
            labals[label] = nil
        }
    }
}
