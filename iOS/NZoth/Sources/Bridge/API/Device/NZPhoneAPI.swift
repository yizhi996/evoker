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
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
        switch self {
            case .makePhoneCall:
            makePhoneCall(args: args, bridge: bridge)
            }
        }
    }

    private func makePhoneCall(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
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
