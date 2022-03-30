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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
        switch self {
            case .getClipboardData:
            getClipboardData(args: args, bridge: bridge)
            case .setClipboardData:
            setClipboardData(args: args, bridge: bridge)
            }
        }
    }
    
    private func getClipboardData(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        let data = UIPasteboard.general.string ?? ""
        bridge.invokeCallbackSuccess(args: args, result: ["data": data])
    }
    
    private func setClipboardData(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
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
