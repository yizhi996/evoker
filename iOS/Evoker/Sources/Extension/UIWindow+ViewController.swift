//
//  UIWindow+ViewController.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController = rootViewController {
            return UIWindow.getVisibleViewControllerFrom(viewController: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(viewController: UIViewController) -> UIViewController {
        switch viewController {
        case let navigationController as UINavigationController:
            return getVisibleViewControllerFrom(viewController: navigationController.visibleViewController!)
        case let tabBarController as UITabBarController:
            return getVisibleViewControllerFrom(viewController: tabBarController.selectedViewController!)
        default:
            if let presentedViewController = viewController.presentedViewController {
                if let presentedViewController2 = presentedViewController.presentedViewController {
                    return getVisibleViewControllerFrom(viewController: presentedViewController2)
                }
            }
            return viewController
        }
    }
}

extension UIViewController {
    
    class func visibleViewController() -> UIViewController? {
        return UIApplication.shared.keyWindow?.visibleViewController()
    }
}
