//
//  InteractionAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum InteractionAPI: String, CaseIterableAPI {
   
    case showModal
    case showToast
    case hideToast
    case showActionSheet
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .showModal:
                showModal(appService: appService, bridge: bridge, args: args)
            case .showToast:
                showToast(appService: appService, bridge: bridge, args: args)
            case .hideToast:
                hideToast(appService: appService, bridge: bridge, args: args)
            case .showActionSheet:
                showActionSheet(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func showModal(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params: Alert.Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.pages.last?.viewController else {
            let error = EVError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let alertView = Alert(params: params)
        let cover = CoverView(contentView: alertView)
        alertView.confirmHandler = { input in
            cover.hide()
            let content = params.editable ? input : ""
            bridge.invokeCallbackSuccess(args: args, result: ["content": content, "confirm": true, "cancel": false])
        }
        alertView.cancelHandler = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["content": "", "confirm": false, "cancel": true])
        }
        cover.show(to: viewController.view)
    }
    
    private func showToast(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params: Toast.Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = EVError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let toast = Toast(params: params, appId: appService.appId, envVersion: appService.envVersion)
        toast.show(to: viewController.view)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideToast(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        Toast.global?.hide()
        Toast.global = nil
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func showActionSheet(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params: ActionSheet.Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = EVError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let actionSheet = ActionSheet(params: params)
        let cover = CoverView.init(contentView: actionSheet)
        cover.clickHandler = {
            cover.hide()
            bridge.invokeCallbackFail(args: args, error: EVError.bridgeFailed(reason: .cancel))
        }
        actionSheet.confirmHandler = { selected in
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["tapIndex": selected])
        }
        actionSheet.cancelHandler = {
            cover.hide()
            bridge.invokeCallbackFail(args: args, error: EVError.bridgeFailed(reason: .cancel))
        }
        cover.show(to: viewController.view)
    }
}
