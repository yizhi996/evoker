//
//  PageViewController.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class PageViewController: UIViewController {
    
    lazy var navigationBar = NavigationBar()
    
    public private(set) var page: Page
    
    var isFirstLoad = true
    
    var loadCompletedHandler: EmptyBlock?
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return page.navigationBarTextStyle == .black ? .default : .lightContent
    }
    
    public init(page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
        
        self.page.viewController = self
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        page.isVisible = true
        
        setupNavigationBar()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        page.isVisible = true
        addInteractivePopGesture()
        addNavigationBarTransitionAnimate()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        addInteractivePopGesture()
        
        guard let appService = page.appService else { return }
        appService.currentPage = page
        
        loadCompletedHandler?()
        loadCompletedHandler = nil
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        page.isVisible = false
    }
    
    @objc func onBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func addNavigationBarTransitionAnimate() {
        transitionCoordinator?.animate(alongsideTransition: { context in
            let containerView = context.containerView
            
            guard let toViewController = context.viewController(forKey: .to) as? PageViewController,
                  let fromViewController = context.viewController(forKey: .from) as? PageViewController else {
                      return
            }
            
            let toView = context.view(forKey: .to)!
            let fromView = context.view(forKey: .from)!
            
            let fromViewControllerHasNavigationBar = fromViewController.page.navigationStyle == .default
            let toViewControllerHasNavigationBar = toViewController.page.navigationStyle == .default
            
            if fromViewControllerHasNavigationBar {
                containerView.addSubview(fromViewController.navigationBar)
                fromViewController.navigationBar.alpha = 1.0
            }
            if toViewControllerHasNavigationBar {
                containerView.addSubview(toViewController.navigationBar)
                toViewController.navigationBar.alpha = 0.0
            }
            
            let options = UIView.AnimationOptions(rawValue: UInt(context.completionCurve.rawValue << 16))
            UIView.animate(withDuration: context.transitionDuration, delay: 0, options: options) {
                if fromViewControllerHasNavigationBar {
                    fromViewController.navigationBar.alpha = 0.0
                }
                if toViewControllerHasNavigationBar {
                    toViewController.navigationBar.alpha = 1.0
                }
            } completion: { finished in
                if toViewControllerHasNavigationBar {
                    toView.addSubview(toViewController.navigationBar)
                }
                if fromViewControllerHasNavigationBar {
                    fromViewController.navigationBar.alpha = 1.0
                    fromView.addSubview(fromViewController.navigationBar)
                }
            }
        })
    }
    
    func addInteractivePopGesture() {
        if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
            navigationController.interactivePopGestureRecognizer?.delegate = self
            
            if page.navigationStyle == .default {
                navigationBar.addBackButton() { [unowned self] in
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    open func setupNavigationBar() {
        if page.navigationStyle == .default {
            navigationBar.setTitle(page.title)
            navigationBar.color = page.navigationBarTextStyle
            navigationBar.backgroundColor = page.navigationBarBackgroundColor
            navigationBar.frame = CGRect(x: 0,
                                         y: 0,
                                         width: view.frame.width,
                                         height: Constant.statusBarHeight + Constant.navigationBarHeight)
            view.addSubview(navigationBar)
        }
    }
    
}

// InteractivePopGestureRecognizer required
extension PageViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return Engine.shared.shouldInteractivePopGesture
    }
}
