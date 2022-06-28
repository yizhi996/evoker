//
//  LocationAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum LocationAPI: String, CaseIterableAPI {
   
    case getLocation
    case startLocationUpdate
    case stopLocationUpdate
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
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
            
    private func getLocation(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let module: LocationModule = appService.getModule() else {
            let error = EVError.bridgeFailed(reason: .moduleNotFound(LocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: OnceLocationManager.GetLocationParams = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.onceLocationManager.getLocation(params: params) { data, error in
            if let error = error {
                let error = EVError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            } else {
                bridge.invokeCallbackSuccess(args: args, result: data)
            }
        }
    }
    
    private func startLocationUpdate(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let type: LocationType
        }
        
        guard let module: LocationModule = appService.getModule() else {
            let error = EVError.bridgeFailed(reason: .moduleNotFound(LocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.isStartUpdatingLocation = true
        module.locationManager.startLocationUpdate(type: params.type) { [weak bridge] data, error in
            guard let bridge = bridge else { return }
            if let error = error {
                bridge.subscribeHandler(method: LocationModule.onLocationChangeErrorSubscribeKey,
                                        data: ["errMsg": error.localizedDescription])
            } else {
                bridge.subscribeHandler(method: LocationModule.onLocationChangeSubscribeKey, data: data!)
            }
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func stopLocationUpdate(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {    
        guard let module: LocationModule = appService.getModule() else {
            let error = EVError.bridgeFailed(reason: .moduleNotFound(LocationModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        module.isStartUpdatingLocation = false
        module.locationManager.stopLocationUpdate()
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
