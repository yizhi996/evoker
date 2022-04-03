//
//  NZCameraModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZCameraModule: NZModule {
    
    typealias PageId = Int
    
    static var name: String {
        return "com.nozthdev.module.camera"
    }
    
    static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZCameraAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    lazy var cameras: [PageId: NZCameraEngine] = [:]
    
    lazy var uiCamera = UICameraEngine()
    
    required init(appService: NZAppService) {
        
    }
    
    func onUnload(_ page: NZPage) {
        cameras[page.pageId]?.stopRunning()
        cameras[page.pageId] = nil
    }
    
}
