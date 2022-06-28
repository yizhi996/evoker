//
//  MapModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public class MapModule: Module {
    
    public static var name: String {
        return "com.evokerdev.module.map"
    }
    
    public static var apis: [String : API] {
        var result: [String : API] = [:]
        MapAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    var mapViews: [Int: MapView] = [:]
    
    public required init(appService: AppService) {

    }
    
    public func onUnload(_ page: Page) {
        mapViews[page.pageId] = nil
    }

}
