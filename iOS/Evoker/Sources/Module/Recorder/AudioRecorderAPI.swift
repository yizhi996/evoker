//
//  AudioRecorderAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

enum AudioRecorderAPI: String, CaseIterableAPI {
    
    case operateAudioRecorder
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .operateAudioRecorder:
                self.operateAudioRecorder(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func operateAudioRecorder(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let method: Method
            var startData: AudioRecorder.Params?
            
            enum Method: String, Decodable {
                case start
                case stop
                case pause
                case resume
            }
        }
        
        guard let module: AudioRecorderModule = appService.getModule() else {
            let error = EKError.bridgeFailed(reason: .moduleNotFound(AudioRecorderModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .start:
            if let params = params.startData {
                module.recorder.startRecord(params: params)
            } else {
                bridge.subscribeHandler(method: AudioRecorderModule.onErrorSubscribeKey,
                                        data: ["error": "start options invalid"])
            }
        case .stop:
            module.recorder.stop()
        case .pause:
            module.recorder.pause()
        case .resume:
            module.recorder.resume()
        }
    }
}
