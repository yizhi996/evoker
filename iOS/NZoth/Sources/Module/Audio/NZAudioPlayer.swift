//
//  NZAudioPlayer.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import KTVHTTPCache

class NZAudioPlayer: NZPlayer {
    
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

extension NZAudioPlayer {
    
    static let onCanplaySubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_CANPLAY")
    
    static let onPlaySubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_PLAY")
    
    static let onPauseSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_PAUSE")
    
    static let onStopSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_STOP")
    
    static let onEndedSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_ENDED")
    
    static let onTimeUpdateSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_TIME_UPDATE")
    
    static let onBufferUpdateSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_BUFFER_UPDATE")
    
    static let onSeekingSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_SEEKING")
    
    static let onSeekedSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_SEEKED")
    
    static let onErrorSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_ERROR")
    
    static let onWaitingSubscribeKey = NZSubscribeKey("MODULE_INNER_AUDIO_CONTEXT_ON_WAITING")
    
}
