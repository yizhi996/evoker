//
//  BatteryAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum BatteryAPI: String, CaseIterableAPI {
   
    case getBatteryInfo
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getBatteryInfo:
                getBatteryInfo(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getBatteryInfo(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = Int(UIDevice.current.batteryLevel * 100)
        let isCharging = UIDevice.current.batteryState == .charging
        UIDevice.current.isBatteryMonitoringEnabled = false
        let result: [String: Any] = ["level": level, "isCharging": isCharging]
        bridge.invokeCallbackSuccess(args: args, result: result)
    }
    
}
