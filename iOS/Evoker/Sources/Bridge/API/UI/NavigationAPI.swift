//
//  NavigationAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NavigationAPI: String, CaseIterableAPI {
   
    case setNavigationBarTitle
    case showNavigationBarLoading
    case hideNavigationBarLoading
    case setNavigationBarColor
    case hideHomeButton
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .setNavigationBarTitle:
                setNavigationBarTitle(appService: appService, bridge: bridge, args: args)
            case .showNavigationBarLoading:
                showNavigationBarLoading(appService: appService, bridge: bridge, args: args)
            case .hideNavigationBarLoading:
                hideNavigationBarLoading(appService: appService, bridge: bridge, args: args)
            case .setNavigationBarColor:
                setNavigationBarColor(appService: appService, bridge: bridge, args: args)
            case .hideHomeButton:
                hideHomeButton(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func setNavigationBarTitle(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let title = params["title"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("title"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webPage = appService.currentPage as? WebPage else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webPage.setTitle(title)
        bridge.invokeCallbackSuccess(args: args, result: [:])
    }
    
    private func showNavigationBarLoading(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let viewController = appService.currentPage?.viewController as? WebPageViewController else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = true
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideNavigationBarLoading(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let viewController = appService.currentPage?.viewController else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = false
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setNavigationBarColor(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let _frontColor: AppConfig.Style.NavigationBarTextStyle
            let backgroundColor: String
            let animation: Animation
        }
        
        struct Animation: Decodable {
            let duration: TimeInterval
            let timingFunc: AnimationFunc
        }
        
        enum AnimationFunc: String, Decodable {
            case linear
            case easeIn
            case easeOut
            case easeInOut
            
            func toNatively() -> UIView.AnimationOptions {
                switch self {
                case .linear:
                    return .curveLinear
                case .easeIn:
                    return .curveEaseIn
                case .easeOut:
                    return .curveEaseOut
                case .easeInOut:
                    return .curveEaseInOut
                }
            }
        }
        
        guard let page = appService.currentPage else {
            let error = EKError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = EKError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIView.animate(withDuration: params.animation.duration / 1000,
                       delay: 0,
                       options: params.animation.timingFunc.toNatively()) {
            viewController.navigationBar.backgroundColor = params.backgroundColor.hexColor()
            page.setNavigationBarTextStyle(params._frontColor)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideHomeButton(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        appService.currentPage?.viewController?.navigationBar.hideGotoHomeButton()
        bridge.invokeCallbackSuccess(args: args)
    }

}
