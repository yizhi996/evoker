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
   
    case showPickerView
    case showMultiPickerView
    case showDatePickerView
    case updateMultiPickerView
    case operateScrollView
    case pageScrollTo
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .showPickerView:
                showPickerView(appService: appService, bridge: bridge, args: args)
            case .showMultiPickerView:
                showMultiPickerView(appService: appService, bridge: bridge, args: args)
            case .showDatePickerView:
                showDatePickerView(appService: appService, bridge: bridge, args: args)
            case .updateMultiPickerView:
                updateMultiPickerView(appService: appService, bridge: bridge, args: args)
            case .operateScrollView:
                operateScrollView(appService: appService, bridge: bridge, args: args)
            case .pageScrollTo:
                pageScrollTo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func showPickerView(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
        
        let picker = NZPickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = NZCoverView(contentView: container)
        
        let onCancel = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": -1])
        }
        
        cover.clickHandler = onCancel
        
        container.onConfirmHandler = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": picker.currentIndex])
        }
        
        container.onCancelHandler = onCancel
        
        cover.show(to: viewController.view)
    }
    
    private func showMultiPickerView(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
        
        let picker = NZMultiPickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = NZCoverView(contentView: container)
        
        let onCancel = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": "cancel"])
        }
        
        cover.clickHandler = onCancel
        
        container.onConfirmHandler = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": picker.currentIndex])
        }
        
        container.onCancelHandler = onCancel
        
        picker.columnChangeHandler = { column, value in
            bridge.subscribeHandler(method: NZMultiPickerView.onChangeColumnSubscribeKey,
                                    data: ["column": column, "value": value])
        }
        cover.show(to: viewController.view)
    }
    
    private func showDatePickerView(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
        
        let picker = NZDatePickerView(data: params)
        let container = NZPickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = NZCoverView.init(contentView: container)
        
        let onCancel = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["value": "cancel"])
        }
        
        cover.clickHandler = onCancel
        
        container.onConfirmHandler = {
            cover.hide()
            let value = picker.fmt.string(from: picker.picker.date)
            bridge.invokeCallbackSuccess(args: args, result:  ["value": value])
        }
        container.onCancelHandler = onCancel
        
        cover.show(to: viewController.view)
    }
    
    private func updateMultiPickerView(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
    
    private func operateScrollView(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let parentId: String
            let scrollViewId: Int
            let bounces: Bool
            let showScrollbar: Bool
            let pagingEnabled: Bool
            let fastDeceleration: Bool
        }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
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
    
    private func pageScrollTo(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let top: CGFloat
            let duration: TimeInterval
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIView.animate(withDuration: params.duration / 1000, delay: 0, options: .curveEaseInOut) {
            let top = min(max(0, params.top - webView.scrollView.frame.height),
                          max(0, webView.scrollView.contentSize.height - webView.scrollView.frame.height))
            webView.scrollView.contentOffset = CGPoint(x: 0, y: top)
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
