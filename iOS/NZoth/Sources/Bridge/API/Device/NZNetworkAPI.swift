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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .getNetworkType:
                getNetworkType(args: args, bridge: bridge)
            case .getLocalIPAddress:
                getLocalIPAddress(args: args, bridge: bridge)
            }
        }
    }
    
    private func getNetworkType(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        let netType = NZEngine.shared.networkType.rawValue
        bridge.invokeCallbackSuccess(args: args, result: ["networkType": netType])
    }
    
    private func getLocalIPAddress(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        bridge.invokeCallbackSuccess(args: args, result: ["localip": Network.getIPAddress()])
    }
    
}
