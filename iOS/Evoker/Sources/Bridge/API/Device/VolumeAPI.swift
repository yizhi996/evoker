//
//  VolumeAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import MediaPlayer

enum VolumeAPI: String, CaseIterableAPI {
    
    case getVolume
    case setVolume
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getVolume:
                getVolume(appService: appService, bridge: bridge, args: args)
            case .setVolume:
                setVolume(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getVolume(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        var volume = Engine.shared.volumeSlider.value
        if volume == 0 {
            volume = AVAudioSession.sharedInstance().outputVolume
        }
        bridge.invokeCallbackSuccess(args: args, result: ["volume": volume])
    }
    
    private func setVolume(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let volume: Float
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            Engine.shared.volumeSlider.value = params.volume
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
