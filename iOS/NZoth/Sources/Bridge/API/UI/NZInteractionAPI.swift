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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .showModal:
                showModal(args: args, bridge: bridge)
            case .showToast:
                showToast(args: args, bridge: bridge)
            case .hideToast:
                hideToast(args: args, bridge: bridge)
            case .showActionSheet:
                showActionSheet(args: args, bridge: bridge)
            }
        }
    }
    
    private func showModal(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params: NZAlertView.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
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
    
    private func showToast(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
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
    
    private func hideToast(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {

    }
    
    private func showActionSheet(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
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
