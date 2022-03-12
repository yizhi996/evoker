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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .setNavigationBarTitle:
                setNavigationBarTitle(args: args, bridge: bridge)
            case .showNavigationBarLoading:
                showNavigationBarLoading(args: args, bridge: bridge)
            case .hideNavigationBarLoading:
                hideNavigationBarLoading(args: args, bridge: bridge)
            case .setNavigationBarColor:
                setNavigationBarColor(args: args, bridge: bridge)
            case .hideHomeButton:
                hideHomeButton(args: args, bridge: bridge)
            }
        }
    }
    
    private func setNavigationBarTitle(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
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
    
    private func showNavigationBarLoading(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.currentPage?.viewController as? NZWebPageViewController else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = true
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideNavigationBarLoading(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        viewController.navigationBar.isLoading = false
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setNavigationBarColor(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let frontColor: String
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
        
        guard let appService = bridge.appService else { return }
        
        guard let viewController = appService.currentPage?.viewController else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIView.animate(withDuration: params.animation.duration,
                       delay: 0,
                       options: params.animation.timingFunc.toNatively()) {
            viewController.navigationBar.backgroundColor = params.backgroundColor.hexColor()
            viewController.navigationBar.color = params.frontColor.hexColor()
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideHomeButton(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        appService.uiControl.removeGotoHomeButton()
        bridge.invokeCallbackSuccess(args: args)
    }

}
