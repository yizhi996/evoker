//
//  NZInteractionAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZInteractionAPI: String, NZBuiltInAPI {
   
    case showModal
    case showToast
    case hideToast
    case showActionSheet
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
    
    private func showModal(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params: NZAlertView.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.pages.last?.viewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let alertView = NZAlertView(params: params)
        let cover = NZCoverView(contentView: alertView)
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
    
    private func showToast(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params: NZToast.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let toast = NZToast(params: params, appId: appService.appId, envVersion: appService.envVersion)
        toast.show(to: viewController.view)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideToast(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {

    }
    
    private func showActionSheet(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params: NZActionSheet.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let actionSheet = NZActionSheet(params: params)
        let cover = NZCoverView.init(contentView: actionSheet)
        cover.clickHandler = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["tapIndex": -1])
        }
        actionSheet.confirmHandler = { selected in
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["tapIndex": selected])
        }
        actionSheet.cancelHandler = {
            cover.hide()
            bridge.invokeCallbackSuccess(args: args, result: ["tapIndex": -1])
        }
        cover.show(to: viewController.view)
    }
}
