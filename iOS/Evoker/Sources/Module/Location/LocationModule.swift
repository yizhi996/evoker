//
//  LocationModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class LocationModule: Module {
    
    static var name: String {
        return "com.evokerdev.module.location"
    }
    
    lazy var onceLocationManager = OnceLocationManager()
    
    lazy var locationManager = LocationManager()
    
    var isStartUpdatingLocation = false
    
    static var apis: [String : API] {
        var result: [String : API] = [:]
        LocationAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    required init(appService: AppService) {
        
    }
    
    func onShow(_ service: AppService) {
        if isStartUpdatingLocation {
            locationManager.locationManager.startUpdatingLocation()
        }
    }
    
    func onHide(_ service: AppService) {
        if isStartUpdatingLocation {
            locationManager.locationManager.stopUpdatingLocation()
        }
    }
}

extension LocationModule {
    
    public static let onLocationChangeSubscribeKey = SubscribeKey("MODULE_LOCATION_ON_CHANGE")
    
    public static let onLocationChangeErrorSubscribeKey = SubscribeKey("MODULE_LOCATION_ON_CHANGE_ERROR")
}
