//
//  NavigationController.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NavigationController: UINavigationController {
    
    var themeChangeHandler: StringBlock?
    
    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? .portrait
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }
    
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
       
    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                themeChangeHandler?(traitCollection.userInterfaceStyle == .dark ? "dark" : "light")
            }
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        navigationBar.isTranslucent = false
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        setNavigationBarHidden(true, animated: false)
        
        view.backgroundColor = .white
        
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NavigationController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { context in
                if !context.isCancelled {
                    let viewController = viewController as! PageViewController
                    if let webPage = viewController.page.appService?.currentPage as? WebPage {
                        webPage.publishOnUnload()
                    }
                    if let webPage = viewController.page as? WebPage {
                        webPage.publishOnShow(publish: true)
                    }
                    viewController.page.appService?.currentPage = viewController.page
                }
            }
        }
    }
}
