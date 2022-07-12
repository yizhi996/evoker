//
//  AudioAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum AudioAPI: String, CaseIterableAPI {
    
    case operateInnerAudioContext
    case setInnerAudioOption
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .operateInnerAudioContext:
                operateInnerAudioContext(appService: appService, bridge: bridge, args: args)
            case .setInnerAudioOption:
                setInnerAudioOption(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func operateInnerAudioContext(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let audioId: Int
            let method: Method
            let data: Data
            
            enum Method: String, Decodable {
                case play
                case pause
                case stop
                case replay
                case seek
                case setVolume
                case setSrc
                case setPlaybackRate
                case destroy
            }
            
            enum Data: Decodable {
                case play(AudioPlayer.Params)
                case seek(SeekData)
                case setVolume(SetVolumeData)
                case setSrc(SetSrcData)
                case setPlaybackRate(SetPlaybackRateData)
                case unknown
                
                struct SeekData: Decodable {
                    let position: Double
                }
                
                struct SetVolumeData: Decodable {
                    let volume: Float
                }
                
                struct SetSrcData: Decodable {
                    let src: String
                }
                
                struct SetPlaybackRateData: Decodable {
                    let rate: Float
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let data = try? container.decode(AudioPlayer.Params.self) {
                        self = .play(data)
                        return
                    }
                    if let data = try? container.decode(SeekData.self) {
                        self = .seek(data)
                        return
                    }
                    if let data = try? container.decode(SetVolumeData.self) {
                        self = .setVolume(data)
                        return
                    }
                    if let data = try? container.decode(SetSrcData.self) {
                        self = .setSrc(data)
                        return
                    }
                    if let data = try? container.decode(SetPlaybackRateData.self) {
                        self = .setPlaybackRate(data)
                        return
                    }
                    self = .unknown
                }
            }
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.currentPage as? WebPage else {
            let error = EKError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: AudioModule = appService.getModule() else {
            let error = EKError.bridgeFailed(reason: .moduleNotFound(AudioModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .play:
            if case .play(var data) = params.data {
                let src = data.src
                data._url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: src) ?? URL(string: src)
                if let player = module.players.get(page.pageId, params.audioId) {
                    player.params = data
                    player.play()
                } else {
                    let player = AudioPlayer(params: data)
                    player.readyToPlayHandler = { duration in
                        bridge.subscribeHandler(method: AudioPlayer.onCanplaySubscribeKey,
                                                data: ["audioId": player.audioId, "duration": duration])
                    }
                    player.playHandler = {
                        bridge.subscribeHandler(method: AudioPlayer.onPlaySubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.pauseHandler = {
                        bridge.subscribeHandler(method: AudioPlayer.onPauseSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.stopHandler = {
                        bridge.subscribeHandler(method: AudioPlayer.onStopSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.endedHandler = {
                        bridge.subscribeHandler(method: AudioPlayer.onEndedSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.timeUpdateHandler = { time in
                        bridge.subscribeHandler(method: AudioPlayer.onTimeUpdateSubscribeKey,
                                                data: ["audioId": player.audioId, "time": time])
                    }
                    player.seekingHandler = {
                        bridge.subscribeHandler(method: AudioPlayer.onSeekingSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.seekCompletionHandler = { _ in
                        bridge.subscribeHandler(method: AudioPlayer.onSeekedSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.playFailedHandler = { error in
                        bridge.subscribeHandler(method: AudioPlayer.onErrorSubscribeKey,
                                                           data: ["audioId": player.audioId,
                                                                  "errMsg": error])
                    }
                    player.bufferUpdateHandler = { bufferTime in
                        bridge.subscribeHandler(method: AudioPlayer.onBufferUpdateSubscribeKey,
                                                           data: ["audioId": player.audioId,
                                                                  "bufferTime": bufferTime])
                    }
                    player.waitingHandler = { wait in
                        if !wait {
                            return
                        }
                        bridge.subscribeHandler(method: AudioPlayer.onWaitingSubscribeKey,
                                                           data: ["audioId": player.audioId])
                    }
                    player.play()
                    module.players.set(page.pageId, params.audioId, value: player)
                }
            }
        case .pause:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            player.pause()
        case .stop:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            player.stop()
        case .replay:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            player.replay()
        case .seek:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            if case .seek(let data) = params.data {
                player.seek(position: data.position)
            }
        case .setVolume:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            if case .setVolume(let data) = params.data {
                player.setVolume(data.volume)
            }
        case .setSrc:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            if case .setSrc(let data) = params.data {
                let src = data.src
                let url = FilePath.ekFilePathToRealFilePath(appId: appService.appId, filePath: src) ?? URL(string: src)
                player.params?._url = url
            }
        case .setPlaybackRate:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            if case .setPlaybackRate(let data) = params.data {
                player.setPlaybackRate(data.rate)
            }
        case .destroy:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            player.destroy()
            module.players.remove(page.pageId, params.audioId)
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func setInnerAudioOption(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let mixWithOther: Bool?
            let obeyMuteSwitch: Bool?
            let speakerOn: Bool?
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: AudioModule = appService.getModule() else {
            let error = EKError.bridgeFailed(reason: .moduleNotFound(AudioModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let mixWithOther = params.mixWithOther {
            module.mixWithOther = mixWithOther
        }
        if let obeyMuteSwitch = params.obeyMuteSwitch {
            module.obeyMuteSwitch = obeyMuteSwitch
        }
        if let speakerOn = params.speakerOn {
            module.speakerOn = speakerOn
        }
        module.setAudioCategory()
    }
}
