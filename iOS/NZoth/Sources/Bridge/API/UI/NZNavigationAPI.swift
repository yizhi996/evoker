//
//  NZNavigationAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Telegraph

enum NZNavigationAPI: String, NZBuiltInAPI {
   
    case setNavigationBarTitle
    case showNavigationBarLoading
    case hideNavigationBarLoading
    case setNavigationBarColor
    case hideHomeButton
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
    
    private func setNavigationBarTitle(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let title = params["title"] as? String else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("title"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webPage = appService.currentPage as? NZWebPage else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        webPage.setTitle(title)
        bridge.invokeCallbackSuccess(args: args, result: [:])
    }
    
    private func showNavigationBarLoading(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let viewController = appService.currentPage?.viewController as? NZWebPageViewController else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = true
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideNavigationBarLoading(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = false
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setNavigationBarColor(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let _frontColor: NZPageStyle.NavigationBarTextStyle
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
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .visibleViewControllerNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
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
    
    private func hideHomeButton(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        appService.currentPage?.viewController?.navigationBar.hideGotoHomeButton()
        bridge.invokeCallbackSuccess(args: args)
    }

}
