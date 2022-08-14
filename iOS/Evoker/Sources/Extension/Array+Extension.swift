//
//  Array+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

extension Array {
    
    func first<T>(ofType: T.Type) -> T? {
        return first { $0 as? T != nil } as? T
    }
    
    func filter<T>(ofType: T.Type) -> [T] {
        return compactMap { $0 as? T }
      }
}
