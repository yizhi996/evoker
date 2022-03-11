//
//  NZCanvasModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore
import SDWebImage

public class NZCanvasModule: NZModule {
    
    public static var name: String {
        return "com.nozthdev.module.canvas"
    }
    
    public static var apis: [String : NZAPI] {
        return [:]
    }
    
    let module = NZCanvas2DImpl()
    
    public weak var appService: NZAppService?
    
    public required init(appService: NZAppService) {
        self.appService = appService
        
        appService.context.binding(module, name: "Canvas2D")
    }
    
    public func willExitPage(_ page: NZPage) {
        
    }
    
}

@objc public protocol NZCanvas2DExport: JSExport {
    
    init()
    
    func exec(_ commands: [[Any]], canvasId: Int)

}

@objc public class NZCanvas2DImpl: NSObject, NZCanvas2DExport {
        
    public override required init() {
        super.init()
    }
    
    public func exec(_ commands: [[Any]], canvasId: Int) {
        
    }
    
}
