//
//  NZNetworkAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZNetworkAPI: String, NZBuiltInAPI {
    
    case getNetworkType
    case getLocalIPAddress
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getNetworkType:
                getNetworkType(appService: appService, bridge: bridge, args: args)
            case .getLocalIPAddress:
                getLocalIPAddress(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getNetworkType(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        let netType = NZEngine.shared.networkType.rawValue
        bridge.invokeCallbackSuccess(args: args, result: ["networkType": netType])
    }
    
    private func getLocalIPAddress(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        bridge.invokeCallbackSuccess(args: args, result: ["localip": Network.getIPAddress()])
    }
    
}
