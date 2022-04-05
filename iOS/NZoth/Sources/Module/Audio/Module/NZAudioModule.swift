//
//  NZAudioModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZAudioModule: NSObject, NZModule {
    
    typealias PageId = Int
    
    typealias AudioId = Int
    
    static var name: String {
        return "com.nozthdev.module.audio"
    }
    
    static var apis: [String : NZAPI] {
        var apis: [String: NZAPI] = [:]
        NZAudioAPI.allCases.forEach { apis[$0.rawValue] = $0 }
        return apis
    }
    
    weak var appService: NZAppService?
    
    lazy var players: DoubleLevelDictionary<PageId, AudioId, NZAudioPlayer> = DoubleLevelDictionary()
    
    required init(appService: NZAppService) {
        super.init()
        self.appService = appService
    }
    
    func onUnload(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.stop() }
        players.remove(page.pageId)
    }

}

extension NZAudioModule: NZAudioPlayerDelegate {
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, canplay duration: Double) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onCanplaySubscribeKey,
                                           data: ["audioId": audioPlayer.audioId, "duration": duration])
    }
    
    func didStartPlay(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onPlaySubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func didPausePlay(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onPauseSubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func didStopPlay(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onStopSubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func didEndPlay(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onEndedSubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, timeUpdate time: Double) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onTimeUpdateSubscribeKey,
                                           data: ["audioId": audioPlayer.audioId,"time": time])
    }
    
    func willSeek(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onSeekingSubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func didSeek(audioPlayer: NZAudioPlayer) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onSeekedSubscribeKey, data: ["audioId": audioPlayer.audioId])
    }
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, playFailed error: (Int, Error)) {
        guard let appService = appService else { return }
        appService.bridge.subscribeHandler(method: Self.onErrorSubscribeKey,
                                           data: ["audioId": audioPlayer.audioId,
                                                  "errMsg": error.1.localizedDescription,
                                                  "errCode": error.0])
    }
    
}

extension NZAudioModule {
    
    static let onCanplaySubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_CANPLAY")
    
    static let onPlaySubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_PLAY")
    
    static let onPauseSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_PAUSE")
    
    static let onStopSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_STOP")
    
    static let onEndedSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_ENDED")
    
    static let onTimeUpdateSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_TIME_UPDATE")
    
    static let onSeekingSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_SEEKING")
    
    static let onSeekedSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_SEEKED")
    
    static let onErrorSubscribeKey = NZSubscribeKey("MODULE_AUDIO_CONTEXT_ON_ERROR")
}
