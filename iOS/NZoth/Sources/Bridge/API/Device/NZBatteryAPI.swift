//
//  NZBatteryAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZBatteryAPI: String, NZBuiltInAPI {
   
    case getBatteryInfo
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getBatteryInfo:
                getBatteryInfo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getBatteryInfo(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        let isCharging = UIDevice.current.batteryState == .charging
        UIDevice.current.isBatteryMonitoringEnabled = false
        let result: [String: Any] = ["level": level, "isCharging": isCharging]
        bridge.invokeCallbackSuccess(args: args, result: result)
    }
    
}
