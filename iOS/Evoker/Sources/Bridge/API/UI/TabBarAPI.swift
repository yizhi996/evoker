//
//  TabBarAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum TabBarAPI: String, CaseIterableAPI {
   
    case showTabBar
    case hideTabBar
    case setTabBarStyle
    case showTabBarRedDot
    case hideTabBarRedDot
    case setTabBarBadge
    case removeTabBarBadge
    case setTabBarItem

    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .showTabBar:
                showTabBar(appService: appService, bridge: bridge, args: args)
            case .hideTabBar:
                hideTabBar(appService: appService, bridge: bridge, args: args)
            case .setTabBarStyle:
                setTabBarStyle(appService: appService, bridge: bridge, args: args)
            case .showTabBarRedDot:
                showTabBarRedDot(appService: appService, bridge: bridge, args: args)
            case .hideTabBarRedDot:
                hideTabBarRedDot(appService: appService, bridge: bridge, args: args)
            case .setTabBarBadge:
                setTabBarBadge(appService: appService, bridge: bridge, args: args)
            case .removeTabBarBadge:
                removeTabBarBadge(appService: appService, bridge: bridge, args: args)
            case .setTabBarItem:
                setTabBarItem(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func showTabBar(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let animation: Bool
        }
        
        guard let viewController = appService.rootViewController?.viewControllers.last as? WebPageViewController else {
            let error = EVError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let page = viewController.page
        
        if page.isTabBarPage && !page.isShowTabBar {
            page.isShowTabBar = true
            let y = viewController.view.bounds.maxY - appService.uiControl.tabBarView.frame.height
            if params.animation {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    appService.uiControl.tabBarView.frame.origin = CGPoint(x: 0, y: y)
                }
            } else {
                appService.uiControl.tabBarView.frame.origin = CGPoint(x: 0, y: y)
            }
            viewController.webView.frame.size.height -= appService.uiControl.tabBarView.frame.height
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideTabBar(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let animation: Bool
        }
        
        guard let viewController = appService.rootViewController?.viewControllers.last as? WebPageViewController else {
            let error = EVError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let page = viewController.page
        
        if page.isTabBarPage && page.isShowTabBar {
            page.isShowTabBar = false
            let y = viewController.view.bounds.maxY
            if params.animation {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
                    appService.uiControl.tabBarView.frame.origin = CGPoint(x: 0, y: y)
                }
            } else {
                appService.uiControl.tabBarView.frame.origin = CGPoint(x: 0, y: y)
            }
            viewController.webView.frame.size.height += appService.uiControl.tabBarView.frame.height
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setTabBarStyle(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let color: String?
            let selectedColor: String?
            let backgroundColor: String?
            let borderStyle: AppConfig.TabBar.BorderStyle?
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        if let backgroundColor = params.backgroundColor {
            tabBarView.backgroundColor = backgroundColor.hexColor()
        }
        if let color = params.color {
            tabBarView.tabBarItems.forEach { $0.setTitleColor(color.hexColor(), for: .normal) }
        }
        if let selectedColor = params.selectedColor {
            tabBarView.tabBarItems.forEach { $0.setTitleColor(selectedColor.hexColor(), for: .selected) }
        }
        if let borderStyle = params.borderStyle {
            if borderStyle == .white {
                tabBarView.borderTopView.backgroundColor = UIColor(white: 1, alpha: 0.3)
            } else if borderStyle == .black {
                tabBarView.borderTopView.backgroundColor = UIColor(white: 0, alpha: 0.3)
            }
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func showTabBarRedDot(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.showRedDot()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideTabBarRedDot(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.hideRedDot()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setTabBarBadge(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let index: Int
            let text: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.showBadge(params.text)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func removeTabBarBadge(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.hideBadge()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setTabBarItem(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let index: Int
            let text: String?
            let iconPath: String?
            let selectedIconPath: String?
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        if let text = params.text {
            item.setTitle(text, for: .normal)
        }
        
        func setImage(iconPath: String, state: UIControl.State) {
            if let evfile = FilePath.evFilePathToRealFilePath(appId: appService.appId, filePath: iconPath) {
                let image = UIImage(contentsOfFile: evfile.path)
                item.setImage(image, for: state)
            } else if let url = URL(string: iconPath), (url.scheme == "http" || url.scheme == "https") {
                item.sd_setImage(with: url, for: state, placeholderImage: item.image(for: state))
            } else {
                let iconFile = FilePath.appStaticFilePath(appId: appService.appId,
                                                          envVersion: appService.envVersion,
                                                          src: iconPath)
                let image = UIImage(contentsOfFile: iconFile.path)
                item.setImage(image, for: state)
            }
        }
        
        if let iconPath = params.iconPath, !iconPath.isEmpty {
            setImage(iconPath: iconPath, state: .normal)
        }
        if let iconPath = params.selectedIconPath, !iconPath.isEmpty {
            setImage(iconPath: iconPath, state: .selected)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
}
