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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .getLocation:
                self.getLocation(args: args, bridge: bridge)
            case .startLocationUpdate:
                self.startLocationUpdate(args: args, bridge: bridge)
            case .stopLocationUpdate:
                self.stopLocationUpdate(args: args, bridge: bridge)
            }
        }
    }
            
    private func getLocation(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
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
    
    private func startLocationUpdate(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let type: NZLocationType
        }
        
        guard let appService = bridge.appService else { return }
        
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
    
    private func stopLocationUpdate(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
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
