//
//  CircularLinkedList.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

final class CircularLinkedList<Key: Hashable, Value> {
    
    class Node: Equatable {
        
        var next: Node?
        
        var prev: Node?
        
        var key: Key
        
        var value: Value?
        
        var size: Int = 0
        
        init(key: Key, value: Value) {
            self.key = key
            self.value = value
        }
        
        static func == (lhs: CircularLinkedList<Key, Value>.Node, rhs: CircularLinkedList<Key, Value>.Node) -> Bool {
            return lhs.key == rhs.key
        }
        
    }
    
    private var head: Node?
    
    private var tail: Node?
    
    func insertAtHead(_ node: Node) {
        if let head = head {
            node.next = head
            head.prev = node
            self.head = node
        } else {
            head = node
            tail = node
        }
    }
    
    func moveToHead(_ node: Node) {
        guard head != node else { return }
        
        if tail?.key == node.key {
            tail = node.prev
            tail?.next = nil
        } else {
            node.next?.prev = node.prev
            node.prev?.next = node.next
        }
        
        node.next = head
        node.prev = nil
        head?.prev = node
        head = node
    }
    
    func remove(_ node: Node) {
        if node.next != nil {
            node.next?.prev = node.prev
        }
        if node.prev != nil {
            node.prev?.next = node.next
        }
        if node == head {
            head = node.next
        }
        if node == tail {
            tail = node.prev
        }
    }
    
    func dropLast() -> Node? {
        guard let last = tail else { return nil }
        if head == tail {
            head = nil
            tail = nil
        } else {
            tail = tail?.prev
            tail?.next = nil
        }
        return last
    }
    
    func removeAll() {
        head = nil
        tail = nil
    }
}
