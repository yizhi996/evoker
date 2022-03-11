//
//  NZTabBarItem.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTabBarItem: UIButton {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = 25.0
        
        let textSize = titleLabel!.frame.size
        let iconX = (bounds.width - iconSize) * 0.5
        let iconY = (bounds.height - iconSize - textSize.height) * 0.5
        imageView?.frame = CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize)
        
        let titleX = (bounds.width - textSize.width) * 0.5
        let titleY = imageView!.frame.maxY + 2
        titleLabel?.frame.origin = CGPoint(x: titleX,y: titleY)
    }
}
