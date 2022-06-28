//
//  CameraModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class CameraModule: Module {
    
    typealias PageId = Int
    
    static var name: String {
        return "com.evokerdev.module.camera"
    }
    
    static var apis: [String : API] {
        var result: [String : API] = [:]
        CameraAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    lazy var cameras: [PageId: CameraEngine] = [:]
    
    lazy var uiCamera = UICameraEngine()
    
    required init(appService: AppService) {
        
    }
    
    func onUnload(_ page: Page) {
        cameras[page.pageId]?.stopRunning()
        cameras[page.pageId] = nil
    }
    
    func onShow(_ page: Page) {
        guard let camera = cameras[page.pageId] else { return }
        camera.startRunning()
    }
    
    func onHide(_ page: Page) {
        guard let camera = cameras[page.pageId] else { return }
        camera.stopRunning()
    }
}
