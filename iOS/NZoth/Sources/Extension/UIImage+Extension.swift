//
//  UIImage+Extension.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIImage {
    
    convenience init?(builtIn name: String) {
        self.init(named: name, in: Constant.assetsBundle, compatibleWith: nil)
    }
    
    class func image(light: UIImage, dark: UIImage) -> UIImage {
        if #available(iOS 13.0, *) {
            let imageAsset = UIImageAsset()
            
            let lightMode = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .light)])
            imageAsset.register(light, with: lightMode)
            
            let darkMode = UITraitCollection(traitsFrom: [.current, .init(userInterfaceStyle: .dark)])
            imageAsset.register(dark, with: darkMode)

            return imageAsset.image(with: .current)
        } else {
            return light
        }
    }
    
    class func color(_ color: UIColor) -> UIImage? {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
