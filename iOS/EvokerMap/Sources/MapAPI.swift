//
//  MapAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum MapAPI: String, CaseIterableAPI {
    
    case insertMap
    case updateMap
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertMap:
                insertMap(appService: appService, bridge: bridge, args: args)
            case .updateMap:
                updateMap(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertMap(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = EVError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: MapView.Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = EVError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let mapModule: MapModule = appService.getModule() else {
            let error = EVError.bridgeFailed(reason: .moduleNotFound(MapModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let mapView = MapView(params: params)
        mapView.delegate = webView
        container.addSubview(mapView)
        
        mapModule.mapViews[page.pageId] = mapView
        mapView.autoPinEdgesToSuperviewEdges()
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func updateMap(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let webView = bridge.container as? WebView else {
            let error = EVError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = EVError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: MapView.UpdateParams = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let mapModule: MapModule = appService.getModule() else {
            let error = EVError.bridgeFailed(reason: .moduleNotFound(MapModule.name))
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
