//
//  Uitls.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

func minMax<T: Comparable>(_ x: T, minimum: T, maximum: T) -> T {
    return min(max(minimum, x), maximum)
}

class DoubleLevelDictionary<F: Hashable, S: Hashable, T> {
    
    private var dict: [F: [S: T]] = [:]
    
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
