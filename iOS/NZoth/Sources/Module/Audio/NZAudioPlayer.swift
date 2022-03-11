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
import ZFPlayer
import KTVHTTPCache

class NZAudioPlayer {
    
    struct Params: Decodable {
        let src: String?
        let volume: Float?
    }
    
    var params: Params {
        didSet {
            setup()
        }
    }
    
    var player: AVPlayer?
    
    init(params: Params) {
        self.params = params
        setup()
    }
    
    func setup() {
        guard let src = params.src, let url = URL(string: src) else { return }
        
        if !KTVHTTPCache.proxyIsRunning() {
            do {
                try KTVHTTPCache.proxyStart()
            } catch {
                NZLogger.error("KTVHTTPCache Start failed: \(error)")
            }
        }
        
        if let proxyURL = KTVHTTPCache.proxyURL(withOriginalURL: url) {
            player = AVPlayer(url: proxyURL)
        }
        
        player?.volume = params.volume ?? 1.0
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
}
