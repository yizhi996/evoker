//
//  UIView+Tongceng.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIView {
    
    public class func findWKChildScrollView(view: UIView, tongcengId: String, scrollHeight: CGFloat) -> UIView? {
        let cls: AnyClass = NSClassFromString("WKCompositingView")!
        if view.isKind(of: cls) {
            if view.description.contains(tongcengId) {
                if let scrollView = view.subviews.first as? UIScrollView {
                    scrollView.gestureRecognizers?.forEach { gesture in
                        scrollView.removeGestureRecognizer(gesture)
                    }
                    scrollView.tongcengId = tongcengId
                    return scrollView
                } else {
                    return nil
                }
            }
        }
        
        for subview in view.subviews {
            let childScrollView = findWKChildScrollView(view: subview, tongcengId: tongcengId, scrollHeight: scrollHeight)
            if childScrollView != nil {
                return childScrollView
            }
        }
        
        return nil
    }
    
    public class func findTongCengContainerView(view: UIView, tongcengId: String) -> UIView? {
        if view.isKind(of: UIScrollView.self) {
            let scrollView = view as! UIScrollView
            if scrollView.tongcengId == tongcengId {
                return scrollView.subviews.first { $0.isKind(of: NZNativelyContainerView.self) }
            }
        }
        
        for subview in view.subviews {
            let container = findTongCengContainerView(view: subview, tongcengId: tongcengId)
            if container != nil {
                return container
            }
        }
        
        return nil
    }
}
