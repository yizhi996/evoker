//
//  NZVolumeAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import MediaPlayer

enum NZVolumeAPI: String, NZBuiltInAPI {
    
    case getVolume
    case setVolume
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .getVolume:
                getVolume(appService: appService, bridge: bridge, args: args)
            case .setVolume:
                setVolume(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func getVolume(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        var value: Float = 0
        
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider {
            value = view.value
        }
        bridge.invokeCallbackSuccess(args: args, result: ["volume": value])
    }
    
    private func setVolume(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        struct Params: Decodable {
            let volume: Float
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let volumeView = MPVolumeView()
        if let slider = volumeView.subviews.first(ofType: UISlider.self) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                slider.value = params.volume
            }
        }
        bridge.invokeCallbackSuccess(args: args)
    }
}
