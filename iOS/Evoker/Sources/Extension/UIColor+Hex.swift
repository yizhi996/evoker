//
//  UIColor+Hex.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension String {
    
    func hexColor(alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(hexString: self, alpha: alpha) ?? .black
    }
}

private extension Int {
    func duplicate4bits() -> Int {
        return (self << 4) + self
    }
}

private extension UIColor {
    
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var hex = hexString
        
        if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        
        guard let hexVal = Int(hex, radix: 16) else {
            return nil
        }
        
        switch hex.count {
        case 3:
            self.init(hex3: hexVal, alpha: alpha)
        case 6:
            self.init(hex6: hexVal, alpha: alpha)
        default:
            return nil
        }
    }
}

private extension UIColor {
    
    convenience init?(hex3: Int, alpha: CGFloat) {
        self.init(red:   CGFloat( ((hex3 & 0xF00) >> 8).duplicate4bits() ) / 255.0,
                  green: CGFloat( ((hex3 & 0x0F0) >> 4).duplicate4bits() ) / 255.0,
                  blue:  CGFloat( ((hex3 & 0x00F) >> 0).duplicate4bits() ) / 255.0,
                  alpha: alpha)
    }
    
    convenience init?(hex6: Int, alpha: CGFloat) {
        self.init(red:   CGFloat( (hex6 & 0xFF0000) >> 16 ) / 255.0,
                  green: CGFloat( (hex6 & 0x00FF00) >> 8 ) / 255.0,
                  blue:  CGFloat( (hex6 & 0x0000FF) >> 0 ) / 255.0,
                  alpha: alpha)
    }

}
