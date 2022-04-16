//
//  NZCanvasAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZCanvasAPI: String, NZBuiltInAPI {
    
    case drawCanvas
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        switch self {
        case .drawCanvas:
            drawCanvas(appService: appService, bridge: bridge, args: args)
        }
    }
    
    private func drawCanvas(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
    }
    
}
