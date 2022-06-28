//
//  CanvasAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum CanvasAPI: String, CaseIterableAPI {
    
    case drawCanvas
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        switch self {
        case .drawCanvas:
            drawCanvas(appService: appService, bridge: bridge, args: args)
        }
    }
    
    private func drawCanvas(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
    }
    
}
