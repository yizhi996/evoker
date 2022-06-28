//
//  UIView+Tongceng.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public extension UIView {
    
    func dfsFindSubview<T>(ofType: T.Type) -> T? {
        return dfsFindSubview(where: { $0 as? T != nil }) as? T
    }
    
    func dfsFindSubview(where predicate: (UIView) throws -> Bool) rethrows -> UIView? {
        if try predicate(self) {
            return self
        }
        for sub in subviews {
            if let res = try sub.dfsFindSubview(where: predicate) {
                return res
            }
        }
        return nil
    }
    
    func findWKChildScrollView(tongcengId: String) -> UIScrollView? {
        let cls: AnyClass = NSClassFromString("WKCompositingView")!
        let wkView = dfsFindSubview { view in
            return view.isKind(of: cls) && view.description.contains(tongcengId)
        }
        if let scrollView = wkView?.subviews.first as? UIScrollView {
            scrollView.tongcengId = tongcengId
            return scrollView
        }
        return nil
    }
    
    func findTongCengContainerView(tongcengId: String) -> NativelyContainerView? {
        let wkScrollView = dfsFindSubview { view in
            if let scrollView = view as? UIScrollView, scrollView.tongcengId == tongcengId {
                return true
            }
            return false
        }
        if let wkScrollView = wkScrollView {
            return wkScrollView.subviews.first(ofType: NativelyContainerView.self)
        }
        return nil
    }
}
