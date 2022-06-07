//
//  NZAudioAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZAudioAPI: String, NZBuiltInAPI {
    
    case operateInnerAudioContext
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .operateInnerAudioContext:
                operateInnerAudioContext(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func operateInnerAudioContext(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
            }
            
            enum Data: Decodable {
                case play(NZAudioPlayer.Params)
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
                    if let data = try? container.decode(NZAudioPlayer.Params.self) {
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
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.currentPage as? NZWebPage else {
            let error = NZError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: NZAudioModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZAudioModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .play:
            if case .play(var data) = params.data {
                let src = data.src
                data._url = FilePath.nzFilePathToRealFilePath(appId: appService.appId, filePath: src) ?? URL(string: src)
                if let player = module.players.get(page.pageId, params.audioId) {
                    player.params = data
                    player.play()
                } else {
                    let player = NZAudioPlayer(params: data)
                    player.readyToPlayHandler = { duration in
                        bridge.subscribeHandler(method: NZAudioPlayer.onCanplaySubscribeKey,
                                                data: ["audioId": player.audioId, "duration": duration])
                    }
                    player.playHandler = {
                        bridge.subscribeHandler(method: NZAudioPlayer.onPlaySubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.pauseHandler = {
                        bridge.subscribeHandler(method: NZAudioPlayer.onPauseSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.stopHandler = {
                        bridge.subscribeHandler(method: NZAudioPlayer.onStopSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.endedHandler = {
                        bridge.subscribeHandler(method: NZAudioPlayer.onEndedSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.timeUpdateHandler = { time in
                        bridge.subscribeHandler(method: NZAudioPlayer.onTimeUpdateSubscribeKey,
                                                data: ["audioId": player.audioId, "time": time])
                    }
                    player.seekingHandler = {
                        bridge.subscribeHandler(method: NZAudioPlayer.onSeekingSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.seekCompletionHandler = { _ in
                        bridge.subscribeHandler(method: NZAudioPlayer.onSeekedSubscribeKey,
                                                data: ["audioId": player.audioId])
                    }
                    player.playFailedHandler = { error in
                        bridge.subscribeHandler(method: NZAudioPlayer.onErrorSubscribeKey,
                                                           data: ["audioId": player.audioId,
                                                                  "errMsg": error])
                    }
                    player.waitingHandler = { wait in
                        if !wait {
                            return
                        }
                        bridge.subscribeHandler(method: NZAudioPlayer.onWaitingSubscribeKey,
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
                let url = FilePath.nzFilePathToRealFilePath(appId: appService.appId, filePath: src) ?? URL(string: src)
                player.params?._url = url
            }
        case .setPlaybackRate:
            guard let player = module.players.get(page.pageId, params.audioId) else { break }
            if case .setPlaybackRate(let data) = params.data {
                player.setPlaybackRate(data.rate)
            }
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
