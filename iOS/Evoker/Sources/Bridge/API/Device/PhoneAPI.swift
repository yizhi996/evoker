//
//  PhoneAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum PhoneAPI: String, CaseIterableAPI {
    
    case makePhoneCall
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .makePhoneCall:
            makePhoneCall(appService: appService, bridge: bridge, args: args)
            }
        }
    }

    private func makePhoneCall(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let phoneNumber: String
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let phoneCallURL = URL(string: "tel://\(params.phoneNumber)"),
           UIApplication.shared.canOpenURL(phoneCallURL) {
            UIApplication.shared.open(phoneCallURL)
            bridge.invokeCallbackSuccess(args: args)
        } else {
            let error = EVError.bridgeFailed(reason: .custom("cannot open url: \(params.phoneNumber)"))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}
