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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        switch self {
        case .drawCanvas:
            drawCanvas(args: args, bridge: bridge)
        }
    }
    
    private func drawCanvas(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
    }
    
}
