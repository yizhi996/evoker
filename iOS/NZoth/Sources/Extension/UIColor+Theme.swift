//
//  UIColor+Extension.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIColor {
    
    class var nzWhite: UIColor {
        return UIColor.color(.white, dark: .black)
    }
    
    class var nzBlack: UIColor {
        return UIColor.color(.black, dark: .white)
    }
    
    class var nzTextBlack: UIColor {
        return UIColor.color("#1d1d1f".hexColor(), dark: "#f5f5f7".hexColor())
    }
    
    class func color(_ default: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                return traits.userInterfaceStyle == .dark ? dark : `default`
            }
        } else {
            return `default`
        }
    }
}
