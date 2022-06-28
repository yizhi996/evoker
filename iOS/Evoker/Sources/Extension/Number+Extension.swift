//
//  Number+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

extension UInt64 {
    
    var mb: Double {
        return Double(self) / 1024.0 / 1024.0
    }
}
