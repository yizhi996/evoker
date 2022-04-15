//
//  NZTabBarAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZTabBarAPI: String, NZBuiltInAPI {
   
    case showTabBar
    case hideTabBar
    case setTabBarStyle
    case showTabBarRedDot
    case hideTabBarRedDot
    case setTabBarBadge
    case removeTabBarBadge
    case setTabBarItem

    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .showTabBar:
                showTabBar(args: args, bridge: bridge)
            case .hideTabBar:
                hideTabBar(args: args, bridge: bridge)
            case .setTabBarStyle:
                setTabBarStyle(args: args, bridge: bridge)
            case .showTabBarRedDot:
                showTabBarRedDot(args: args, bridge: bridge)
            case .hideTabBarRedDot:
                hideTabBarRedDot(args: args, bridge: bridge)
            case .setTabBarBadge:
                setTabBarBadge(args: args, bridge: bridge)
            case .removeTabBarBadge:
                removeTabBarBadge(args: args, bridge: bridge)
            case .setTabBarItem:
                setTabBarItem(args: args, bridge: bridge)
            }
        }
    }
    
    private func showTabBar(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let animation: Bool
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.rootViewController?.viewControllers.last as? NZWebPageViewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
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
    
    private func hideTabBar(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let animation: Bool
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.rootViewController?.viewControllers.last as? NZWebPageViewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
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
    
    private func setTabBarStyle(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let color: String?
            let selectedColor: String?
            let backgroundColor: String?
            let borderStyle: NZAppTabBarInfo.BorderStyle?
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
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
    
    private func showTabBarRedDot(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.showRedDot()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideTabBarRedDot(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.hideRedDot()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setTabBarBadge(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let index: Int
            let text: String
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.showBadge(params.text)
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func removeTabBarBadge(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let index: Int
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        item.badgeView.hideBadge()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setTabBarItem(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let index: Int
            let text: String?
            let iconPath: String?
            let selectedIconPath: String?
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let tabBarView = appService.uiControl.tabBarView
        let item = tabBarView.tabBarItems[params.index]
        if let text = params.text {
            item.setTitle(text, for: .normal)
        }
        
        func setImage(iconPath: String, state: UIControl.State) {
            if let nzfile = FilePath.nzFilePathToRealFilePath(appId: appService.appId,
                                                              userId: NZEngine.shared.userId,
                                                              filePath: iconPath) {
                let image = UIImage(contentsOfFile: nzfile.path)
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
