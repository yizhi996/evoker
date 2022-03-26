//
//  NZTongCengAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZTongCengAPI: String, NZBuiltInAPI {
  
    case insertContainer
    case updateContainer
    case removeContainer
    
    struct ContainerParams: Decodable {
        let tongcengId: String
        let position: Position
        let scrollEnabled: Bool?
    }
    
    struct Position: Decodable {
        let width: CGFloat
        let height: CGFloat
        let left: CGFloat
        let top: CGFloat
        let scrollHeight: CGFloat
    }
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .insertContainer:
                insertContainer(args: args, bridge: bridge)
            case .updateContainer:
                updateContainer(args: args, bridge: bridge)
            case .removeContainer:
                removeContainer(args: args, bridge: bridge)
            }
        }
    }
    
    private func insertContainer(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: ContainerParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard !params.tongcengId.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("tongcengId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let scrollView = webView.findWKChildScrollView(tongcengId: params.tongcengId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.tongcengId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if params.scrollEnabled == false {
            scrollView.gestureRecognizers?.forEach { scrollView.removeGestureRecognizer($0) }
            
            let frame = CGRect(x: 0, y: 0, width: params.position.width, height: params.position.height)
            let container = NZNativelyContainerView(frame: frame)
            scrollView.addSubview(container)
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func updateContainer(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: ContainerParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard !params.tongcengId.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("tongcengId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.tongcengId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.tongcengId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let frame = CGRect(x: 0, y: 0, width: params.position.width, height: params.position.height)
        container.frame = frame
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func removeContainer(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard let tongcengId = params["tongcengId"] as? String, !tongcengId.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("tongcengId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: tongcengId) else {
            bridge.invokeCallbackSuccess(args: args)
            return
        }
        
        container.removeFromSuperview()
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
