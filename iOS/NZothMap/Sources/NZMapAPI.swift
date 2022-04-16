//
//  NZMapAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZMapAPI: String, NZBuiltInAPI {
    
    case insertMap
    case updateMap
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertMap:
                insertMap(appService: appService, bridge: bridge, args: args)
            case .updateMap:
                updateMap(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertMap(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZMapView.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let mapModule: NZMapModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZMapModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let mapView = NZMapView(params: params)
        container.addSubview(mapView)
        
        mapModule.mapViews[page.pageId] = mapView
        mapView.autoPinEdgesToSuperviewEdges()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func updateMap(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZMapView.UpdateParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let mapModule: NZMapModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZMapModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let mapView = mapModule.mapViews[page.pageId] else {
            bridge.invokeCallbackFail(args: args, error: .custom("mapView not found"))
            return
        }
        
        mapView.updateParams(params)
        bridge.invokeCallbackSuccess(args: args)
    }
}
