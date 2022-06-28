//
//  CanvasModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore
import SDWebImage

public class CanvasModule: Module {
    
    public static var name: String {
        return "com.evokerdev.module.canvas"
    }
    
    public static var apis: [String : API] {
        return [:]
    }
    
    let module = Canvas2DImpl()
    
    public weak var appService: AppService?
    
    public required init(appService: AppService) {
        self.appService = appService
        
        appService.context.binding(module, name: "Canvas2D")
    }
    
}

@objc public protocol Canvas2DExport: JSExport {
    
    init()
    
    func exec(_ commands: [[Any]], canvasId: Int)

}

@objc public class Canvas2DImpl: NSObject, Canvas2DExport {
        
    public override required init() {
        super.init()
    }
    
    public func exec(_ commands: [[Any]], canvasId: Int) {
        
    }
    
}
