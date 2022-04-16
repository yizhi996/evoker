//
//  NZLocationAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZLocationAPI: String, NZBuiltInAPI {
   
    case getLocation
    case startLocationUpdate
    case stopLocationUpdate
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getLocation:
                self.getLocation(appService: appService, bridge: bridge, args: args)
            case .startLocationUpdate:
                self.startLocationUpdate(appService: appService, bridge: bridge, args: args)
            case .stopLocationUpdate:
                self.stopLocationUpdate(appService: appService, bridge: bridge, args: args)
            }
        }
    }
            
    private func getLocation(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let module: NZLocationModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZLocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: NZOnceLocationManager.GetLocationParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.onceLocationManager.getLocation(params: params) { data, error in
            if let error = error {
                let error = NZError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            } else {
                bridge.invokeCallbackSuccess(args: args, result: data)
            }
        }
    }
    
    private func startLocationUpdate(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let type: NZLocationType
        }
        
        guard let module: NZLocationModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZLocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.isStartUpdatingLocation = true
        module.locationManager.startLocationUpdate(type: params.type) { [weak bridge] data in
            guard let bridge = bridge else { return }
            bridge.subscribeHandler(method: NZSubscribeKey("APP_LOCATION_ON_CHANGE"), data: data)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func stopLocationUpdate(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {    
        guard let module: NZLocationModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZLocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.isStartUpdatingLocation = false
        module.locationManager.stopLocationUpdate()
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
