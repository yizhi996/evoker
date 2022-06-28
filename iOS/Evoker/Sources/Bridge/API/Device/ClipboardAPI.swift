//
//  ClipboardAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum ClipboardAPI: String, CaseIterableAPI {
    
    case getClipboardData
    case setClipboardData
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .getClipboardData:
            getClipboardData(appService: appService, bridge: bridge, args: args)
            case .setClipboardData:
            setClipboardData(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getClipboardData(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        let data = UIPasteboard.general.string ?? ""
        bridge.invokeCallbackSuccess(args: args, result: ["data": data])
    }
    
    private func setClipboardData(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let data: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        UIPasteboard.general.string = params.data
        bridge.invokeCallbackSuccess(args: args)
    }
}
