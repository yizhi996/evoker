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
    case showMultiPickerView
    case showDatePickerView
    case updateMultiPickerView
    case operateScrollView
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .showTabBar:
                showTabBar(args: args, bridge: bridge)
            case .hideTabBar:
                hideTabBar(args: args, bridge: bridge)
            case .showPickerView:
                showPickerView(args: args, bridge: bridge)
            case .showMultiPickerView:
                showMultiPickerView(args: args, bridge: bridge)
            case .showDatePickerView:
                showDatePickerView(args: args, bridge: bridge)
            case .updateMultiPickerView:
                updateMultiPickerView(args: args, bridge: bridge)
            case .operateScrollView:
                operateScrollView(args: args, bridge: bridge)
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
        
        let onCancel = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": -1])
        }
        
        cover.clickHandler = onCancel
        
        let width = viewController.view.frame.width
        let height = width
        container.frame = CGRect(x: 0, y: viewController.view.frame.height - height, width: width, height: height)
        container.onConfirmHandler = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": picker.currentIndex])
        }
        container.onCancelHandler = onCancel
        cover.show(to: viewController.view)
        cover.addSubview(container)
        container.popup()
    }
    
    private func showMultiPickerView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
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
        
        guard let params: NZMultiPickerView.PickData = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let cover = NZCoverView()
        let picker = NZMultiPickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let onHide = {
            cover.hide()
            container.popdown {
                picker.removeFromSuperview()
            }
        }
        
        let onCancel = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": "cancel"])
        }
        
        cover.clickHandler = onCancel
        
        let width = viewController.view.frame.width
        let height = width
        container.frame = CGRect(x: 0, y: viewController.view.frame.height - height, width: width, height: height)
        container.onConfirmHandler = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": picker.currentIndex])
        }
        container.onCancelHandler = onCancel
        picker.columnChangeHandler = { column, value in
            bridge.subscribeHandler(method: NZMultiPickerView.onChangeColumnSubscribeKey,
                                    data: ["column": column, "value": value])
        }
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
        
        let onCancel = {
            onHide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": "cancel"])
        }
        
        cover.clickHandler = onCancel
        
        let width = viewController.view.frame.width
        let height = width
        container.frame = CGRect(x: 0, y: viewController.view.frame.height - height, width: width, height: height)
        container.onConfirmHandler = {
            onHide()
            let value = picker.fmt.string(from: picker.picker.date)
            bridge.invokeCallbackSuccess(args: args, result:  ["value": value])
        }
        container.onCancelHandler = onCancel
        cover.show(to: viewController.view)
        cover.addSubview(container)
        container.popup()
    }
    
    private func updateMultiPickerView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
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
        
        guard let params: NZMultiPickerView.PickData = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let pickerView = viewController.view.dfsFindSubview(ofType: NZMultiPickerView.self) else {
            let error = NZError.bridgeFailed(reason: .custom("picker view not found"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        pickerView.data = params
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateScrollView(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let parentId: String
            let scrollViewId: Int
            let bounces: Bool
            let showScrollbar: Bool
            let pagingEnabled: Bool
            let fastDeceleration: Bool
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let scrollView = webView.findWKChildScrollView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        scrollView.bounces = params.bounces
        scrollView.showsVerticalScrollIndicator = params.showScrollbar
        scrollView.showsHorizontalScrollIndicator = params.showScrollbar
        scrollView.isPagingEnabled = params.pagingEnabled
        scrollView.decelerationRate = params.fastDeceleration ? .fast : .normal
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
