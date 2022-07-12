//
//  TongCengAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum TongCengAPI: String, CaseIterableAPI {
  
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
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertContainer:
                insertContainer(appService: appService, bridge: bridge, args: args)
            case .updateContainer:
                updateContainer(appService: appService, bridge: bridge, args: args)
            case .removeContainer:
                removeContainer(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertContainer(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: ContainerParams = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard !params.tongcengId.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("tongcengId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let scrollView = webView.findWKChildScrollView(tongcengId: params.tongcengId) else {
            let error = EKError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.tongcengId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if params.scrollEnabled == false {
            scrollView.gestureRecognizers?.forEach { scrollView.removeGestureRecognizer($0) }
            
            let frame = CGRect(x: 0, y: 0, width: params.position.width, height: params.position.height)
            let container = NativelyContainerView(frame: frame)
            scrollView.addSubview(container)
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func updateContainer(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: ContainerParams = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard !params.tongcengId.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("tongcengId"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.tongcengId) else {
            let error = EKError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.tongcengId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let frame = CGRect(x: 0, y: 0, width: params.position.width, height: params.position.height)
        container.frame = frame
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func removeContainer(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EKError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
              
        guard let tongcengId = params["tongcengId"] as? String, !tongcengId.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("tongcengId"))
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
