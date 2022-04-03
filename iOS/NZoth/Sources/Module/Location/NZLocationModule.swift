//
//  NZLocationModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class NZLocationModule: NZModule {
    
    static var name: String {
        return "com.nozthdev.module.location"
    }
    
    lazy var onceLocationManager = NZOnceLocationManager()
    
    lazy var locationManager = NZLocationManager()
    
    var isStartUpdatingLocation = false
    
    static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZLocationAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    required init(appService: NZAppService) {
        
    }
    
    func onShow(_ service: NZAppService) {
        if isStartUpdatingLocation {
            locationManager.locationManager.startUpdatingLocation()
        }
    }
    
    func onHide(_ service: NZAppService) {
        if isStartUpdatingLocation {
            locationManager.locationManager.stopUpdatingLocation()
        }
    }
}
