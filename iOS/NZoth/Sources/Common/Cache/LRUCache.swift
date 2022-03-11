//
//  LRUCache.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public final class LRUCache<Key: Hashable, Value> {
    
    public let maxSize: UInt
    
    private let lock = Lock()
    
    private let linkedList = CircularLinkedList<Key, Value>()
    
    private var elements: [Key: CircularLinkedList<Key, Value>.Node] = [:]
    
    public private(set) var totalSize: Int = 0
    
    public init(maxSize: UInt) {
        self.maxSize = maxSize
    }
    
    public func get(_ key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        
        guard let node = elements[key] else { return nil }
        linkedList.moveToHead(node)
        return node.value
    }
    
    public func put(key: Key, value: Value?, size: Int = 0) {
        lock.lock()
        defer { lock.unlock() }
        
        switch elements[key] {
        case .some(let node):
            if value == nil {
                totalSize -= node.size
                linkedList.remove(node)
            } else {
                node.value = value
                totalSize -= node.size
                totalSize += size
                linkedList.moveToHead(node)
            }
        case .none:
            if value == nil {
                break
            }
            let node = CircularLinkedList<Key, Value>.Node(key: key, value: value!)
            node.size = size
            elements[key] = node
            linkedList.insertAtHead(node)
            totalSize += size
        }
        
        if totalSize > maxSize {
            if let node = linkedList.dropLast() {
                elements.removeValue(forKey: node.key)
                totalSize -= node.size
            }
        }
    }
    
    public func removeAll() {
        lock.lock()
        defer { lock.unlock() }
        
        elements = [:]
        totalSize = 0
        linkedList.removeAll()
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return get(key)
        } set {
            put(key: key, value: newValue)
        }
    }
    
}
