//
//  SoundAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import AudioToolbox

enum SoundAPI: String, CaseIterableAPI {
    
    case playSystemSound
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .playSystemSound:
                playSystemSound(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func playSystemSound(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EVError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let id = params["id"] as? UInt32 {
            AudioServicesPlaySystemSound(id)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
