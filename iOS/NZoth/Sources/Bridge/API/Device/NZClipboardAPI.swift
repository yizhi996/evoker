//
//  NZClipboardAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZClipboardAPI: String, NZBuiltInAPI {
    
    case getClipboardData
    case setClipboardData
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .getClipboardData:
            getClipboardData(appService: appService, bridge: bridge, args: args)
            case .setClipboardData:
            setClipboardData(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getClipboardData(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        let data = UIPasteboard.general.string ?? ""
        bridge.invokeCallbackSuccess(args: args, result: ["data": data])
    }
    
    private func setClipboardData(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let data: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIPasteboard.general.string = params.data
        bridge.invokeCallbackSuccess(args: args)
    }
}
