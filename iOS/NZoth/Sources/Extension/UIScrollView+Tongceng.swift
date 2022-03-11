//
//  UIScrollView+Tongceng.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit


extension UIScrollView {
    
    private static var tongcengIdKey = "WK_SCROLL_VIEW_TONGCENG_ID"
    
    var tongcengId: String? {
        get {
            objc_getAssociatedObject(self, &UIScrollView.tongcengIdKey) as! String?
        } set {
            objc_setAssociatedObject(self, &UIScrollView.tongcengIdKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
