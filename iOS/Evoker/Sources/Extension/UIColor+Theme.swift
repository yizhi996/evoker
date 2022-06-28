//
//  UIColor+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIColor {
    
    class var evWhite: UIColor {
        return UIColor.color(.white, dark: .black)
    }
    
    class var evBlack: UIColor {
        return UIColor.color(.black, dark: .white)
    }
    
    class var evTextBlack: UIColor {
        return UIColor.color("#1d1d1f".hexColor(), dark: "#f5f5f7".hexColor())
    }
    
    class func color(_ light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                return traits.userInterfaceStyle == .dark ? dark : light
            }
        } else {
            return light
        }
    }
}
