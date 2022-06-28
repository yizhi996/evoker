//
//  AudioPlayer.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import KTVHTTPCache

class AudioPlayer: Player {
    
    struct Params: Decodable {
        let audioId: Int
        
        let src: String
        
        let volume: Float
        
        let playbackRate: Float
        
        var _url: URL?
    }
    
    let audioId: Int
    
    var params: Params!
    
    init(params: Params) {
        self.params = params
        audioId = params.audioId
        super.init()
        
        if let url = params._url {
            setURL(url)
            playbackRate = params.playbackRate
        }
    }
    
    func changeURL(_ url: URL) {
        params._url = url
        setURL(url)
    }
    
    override func play() {
        super.play()
        setVolume(params.volume)
    }
    
}

extension AudioPlayer {
    
    static let onCanplaySubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_CANPLAY")
    
    static let onPlaySubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_PLAY")
    
    static let onPauseSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_PAUSE")
    
    static let onStopSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_STOP")
    
    static let onEndedSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_ENDED")
    
    static let onTimeUpdateSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_TIME_UPDATE")
    
    static let onBufferUpdateSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_BUFFER_UPDATE")
    
    static let onSeekingSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_SEEKING")
    
    static let onSeekedSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_SEEKED")
    
    static let onErrorSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_ERROR")
    
    static let onWaitingSubscribeKey = SubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_WAITING")
    
}
