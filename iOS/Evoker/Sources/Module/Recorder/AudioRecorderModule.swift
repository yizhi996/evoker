//
//  AudioRecorderModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

class AudioRecorderModule: Module {
    
    static var name: String {
        return "com.evokerdev.module.audio-recorder"
    }
    
    let recorder = AudioRecorder()
    
    static var apis: [String : API] {
        var result: [String : API] = [:]
        AudioRecorderAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    required init(appService: AppService) {
        recorder.onStartHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onStartSubscribeKey, data: [:])
        }
        
        recorder.onStopHandler = { [weak appService] data in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onStopSubscribeKey, data: data)
        }
        
        recorder.onPauseHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onPauseSubscribeKey, data: [:])
        }
        
        recorder.onResumeHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onResumeSubscribeKey, data: [:])
        }
        
        recorder.onInterruptionBeginHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onInterruptionBeginSubscribeKey, data: [:])
        }
        
        recorder.onInterruptionEndHandler = { [weak appService] in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onInterruptionEndSubscribeKey, data: [:])
        }
        
        recorder.onErrorHandler = { [weak appService] error in
            guard let appService = appService else { return }
            appService.bridge.subscribeHandler(method: AudioRecorderModule.onErrorSubscribeKey,
                                               data: ["error": error.localizedDescription])
        }
    }
    
    func onHide(_ service: AppService) {
        recorder.stop()
    }
    
    func onExit(_ service: AppService) {
        recorder.stop()
    }
    
}

extension AudioRecorderModule {
    
    static let onStartSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_START")
    
    static let onStopSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_STOP")
    
    static let onPauseSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_PAUSE")
    
    static let onResumeSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_RESUME")
    
    static let onInterruptionBeginSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_INTERRUPTION_BEGIN")
    
    static let onInterruptionEndSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_INTERRUPTION_END")
    
    static let onErrorSubscribeKey = SubscribeKey("MODULE_AUDIO_RECORDER_ON_ERROR")
}
