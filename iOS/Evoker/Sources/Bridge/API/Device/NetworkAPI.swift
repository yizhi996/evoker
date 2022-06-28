//
//  NetworkAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NetworkAPI: String, CaseIterableAPI {
    
    case getNetworkType
    case getLocalIPAddress
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getNetworkType:
                getNetworkType(appService: appService, bridge: bridge, args: args)
            case .getLocalIPAddress:
                getLocalIPAddress(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getNetworkType(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let netType = Engine.shared.networkType.rawValue
        bridge.invokeCallbackSuccess(args: args, result: ["networkType": netType])
    }
    
    private func getLocalIPAddress(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        bridge.invokeCallbackSuccess(args: args, result: ["localip": Network.getIPAddress()])
    }
    
}
