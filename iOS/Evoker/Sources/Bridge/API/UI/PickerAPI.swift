//
//  PickerAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum PickerAPI: String, CaseIterableAPI {
   
    case showPickerView
    
    case showMultiPickerView
    
    case showDatePickerView
    
    case updateMultiPickerView
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
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
            }
        }
    }
    
    private func showPickerView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: PickerView.PickData = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let picker = PickerView(data: params)
        let container = PickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = CoverView(contentView: container)
        
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
    
    private func showMultiPickerView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: MultiPickerView.PickData = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let picker = MultiPickerView(data: params)
        let container = PickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = CoverView(contentView: container)
        
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
            bridge.subscribeHandler(method: MultiPickerView.onChangeColumnSubscribeKey,
                                    data: ["column": column, "value": value])
        }
        cover.show(to: viewController.view)
    }
    
    private func showDatePickerView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = EKError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: DatePickerView.Data = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let picker = DatePickerView(data: params)
        let container = PickerContainerView(picker: picker)
        container.titleLabel.text = params.title
        
        let cover = CoverView.init(contentView: container)
        
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
    
    private func updateMultiPickerView(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = webView.page?.viewController else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: MultiPickerView.PickData = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let pickerView = viewController.view.dfsFindSubview(ofType: MultiPickerView.self) else {
            let error = EKError.bridgeFailed(reason: .custom("picker view not found"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        pickerView.data = params
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
