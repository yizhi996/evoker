//
//  NZPhoneAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZPhoneAPI: String, NZBuiltInAPI {
    
    case makePhoneCall
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .makePhoneCall:
            makePhoneCall(appService: appService, bridge: bridge, args: args)
            }
        }
    }

    private func makePhoneCall(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let phoneNumber: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let phoneCallURL = URL(string: "tel://\(params.phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL)
            bridge.invokeCallbackSuccess(args: args)
        } else {
            let error = NZError.bridgeFailed(reason: .custom("cannot open url: \(params.phoneNumber)"))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}
