//
//  NZMapModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public class NZMapModule: NZModule {
    
    public static var name: String {
        return "com.nozthdev.module.map"
    }
    
    public static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZMapAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    var mapViews: [Int: NZMapView] = [:]
    
    public required init(appService: NZAppService) {

    }
    
    public func onUnload(_ page: NZPage) {
        mapViews[page.pageId] = nil
    }

}
