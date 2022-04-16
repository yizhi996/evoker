//
//  NZSoundAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import AudioToolbox

enum NZSoundAPI: String, NZBuiltInAPI {
    
    case playSystemSound
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
        switch self {
            case .playSystemSound:
                playSystemSound(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func playSystemSound(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let id = params["id"] as? UInt32 {
            AudioServicesPlaySystemSound(id)
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
}
