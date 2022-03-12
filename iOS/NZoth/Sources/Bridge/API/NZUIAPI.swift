//
//  NZUIAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import MJRefresh

enum NZUIAPI: String, NZBuiltInAPI {
   
    case showTabBar
    case hideTabBar
    case showPickerView
    case showDatePickerView
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .showTabBar:
                showTabBar(args: args, bridge: bridge)
            case .hideTabBar:
                hideTabBar(args: args, bridge: bridge)
            case .showPickerView:
                showPickerView(args: args, bridge: bridge)
            case .showDatePickerView:
                showDatePickerView(args: args, bridge: bridge)
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
    
    private func showPickerView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZPickerView.PickData = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let cover = NZCoverView()
        let picker = NZPickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let onHide = {
            cover.hide()
            container.popdown {
                picker.removeFromSuperview()
            }
        }
        
        let onCancle = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: "cancel")
        }
        
        cover.clickHandler = onCancle
        
        let width = viewController.view.frame.width
        let height = width
        container.frame = CGRect(x: 0, y: viewController.view.frame.height - height, width: width, height: height)
        container.onConfirmHandler = {
            onHide()
            let result = picker.result()
            bridge.invokeCallbackSuccess(args: args, result: result)
        }
        container.onCancelHandler = onCancle
        cover.show(to: viewController.view)
        cover.addSubview(container)
        container.popup()
    }
    
    private func showDatePickerView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZDatePickerView.Data = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let cover = NZCoverView()
        let picker = NZDatePickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let onHide = {
            cover.hide()
            container.popdown {
                picker.removeFromSuperview()
            }
        }
        
        let onCancle = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: "cancel")
        }
        
        cover.clickHandler = onCancle
        
        let width = viewController.view.frame.width
        let height = width
        container.frame = CGRect(x: 0, y: viewController.view.frame.height - height, width: width, height: height)
        container.onConfirmHandler = {
            onHide()
            let value = picker.fmt.string(from: picker.picker.date)
            let result: [String: Any] = ["value": value]
            bridge.invokeCallbackSuccess(args: args, result: result)
        }
        container.onCancelHandler = onCancle
        cover.show(to: viewController.view)
        cover.addSubview(container)
        container.popup()
    }
    
}
