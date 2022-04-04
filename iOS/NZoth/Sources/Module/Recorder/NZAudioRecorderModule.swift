//
//  NZAudioRecorderModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class NZAudioRecorderModule: NZModule {
    
    static var name: String {
        return "com.nozthdev.module.audio-recorder"
    }
    
    let recorder = NZAudioRecorder()
    
    static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZAudioRecorderAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    required init(appService: NZAppService) {
        recorder.onStartHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onStartSubscribeKey, data: [:])
        }
        
        recorder.onStopHandler = { [weak appService] data in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onStopSubscribeKey, data: data)
        }
        
        recorder.onPauseHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onPauseSubscribeKey, data: [:])
        }
        
        recorder.onResumeHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onResumeSubscribeKey, data: [:])
        }
        
        recorder.onInterruptionBeginHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onInterruptionBeginSubscribeKey, data: [:])
        }
        
        recorder.onInterruptionEndHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onInterruptionEndSubscribeKey, data: [:])
        }
        
        recorder.onErrorHandler = { [weak appService] error in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: NZAudioRecorderModule.onErrorSubscribeKey,
                                               data: ["error": error.localizedDescription])
        }
    }
    
    func onExit(_ service: NZAppService) {
        recorder.stop()
    }
}

extension NZAudioRecorderModule {
    
    static let onStartSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_START")
    
    static let onStopSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_STOP")
    
    static let onPauseSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_PAUSE")
    
    static let onResumeSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_RESUME")
    
    static let onInterruptionBeginSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_INTERRUPTION_BEGIN")
    
    static let onInterruptionEndSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_INTERRUPTION_END")
    
    static let onErrorSubscribeKey = NZSubscribeKey("MODULE_AUDIO_RECORDER_ON_ERROR")
}
