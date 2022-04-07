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

protocol NZAudioPlayerDelegate: NSObject {
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, canplay duration: Double)
    
    func didStartPlay(audioPlayer: NZAudioPlayer)
    
    func didPausePlay(audioPlayer: NZAudioPlayer)
    
    func didStopPlay(audioPlayer: NZAudioPlayer)
    
    func didEndPlay(audioPlayer: NZAudioPlayer)
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, timeUpdate time: Double)
    
    func willSeek(audioPlayer: NZAudioPlayer)
    
    func didSeek(audioPlayer: NZAudioPlayer)
    
    func audioPlayer(_ audioPlayer: NZAudioPlayer, playFailed error: (Int, Error))
}

class NZAudioPlayer: NSObject {
    
    struct Params: Decodable {
        let src: String
        let volume: Float
        let playbackRate: Float
        var _url: URL?
    }
    
    var currentPlayURL: URL?
    
    var params: Params? {
        didSet {
            guard let params = params, let url = params._url else { return }
            setURL(url)
        }
    }
    
    var player: AVPlayer?
    
    var playerItem: AVPlayerItem?
    
    var timeObserver: Any?
    
    weak var delegate: NZAudioPlayerDelegate?
    
    let audioId: Int
    
    init(audioId: Int) {
        self.audioId = audioId
        super.init()
    }
    
    deinit {
        timeObserver = nil
        player?.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
        NotificationCenter.default.removeObserver(self)
    }
    
    func setURL(_ url: URL) {
        if currentPlayURL == url {
            return
        }
        currentPlayURL = url
        if !KTVHTTPCache.proxyIsRunning() {
            do {
                try KTVHTTPCache.proxyStart()
            } catch {
                NZLogger.error("KTVHTTPCache Start failed: \(error)")
            }
        }
        
        timeObserver = nil
        
        if let player = player {
            player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.status))
            player.pause()
            player.replaceCurrentItem(with: nil)
            self.player = nil
        }
        
        if let playerItem = playerItem {
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                      object: playerItem)
            self.playerItem = nil
        }
        
        if let proxyURL = KTVHTTPCache.proxyURL(withOriginalURL: url) {
            playerItem = AVPlayerItem(url: proxyURL)
            player = AVPlayer(playerItem: playerItem)
        }
        
        if let player = player, let playerItem = playerItem {
            player.addObserver(self, forKeyPath: #keyPath(AVPlayer.status), options: [.new], context: nil)
            let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
                guard let self = self else { return }
                self.delegate?.audioPlayer(self, timeUpdate: time.seconds)
            }
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onPlayEnded(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
        }
    }
    
    func play() {
        guard let player = player else { return }
        player.play()
        player.volume = params?.volume ?? 1.0
        player.rate = params?.playbackRate ?? 1.0
        delegate?.didStartPlay(audioPlayer: self)
    }
    
    func pause() {
        guard let player = player, let playerItem = playerItem else { return }
        player.pause()
        playerItem.cancelPendingSeeks()
        delegate?.didPausePlay(audioPlayer: self)
    }
    
    func stop() {
        guard let player = player, let playerItem = playerItem else { return }
        playerItem.cancelPendingSeeks()
        player.pause()
        player.seek(to: .zero)
        delegate?.didStopPlay(audioPlayer: self)
    }
    
    func replay() {
        guard let player = player, let playerItem = playerItem else { return }
        playerItem.cancelPendingSeeks()
        player.pause()
        player.seek(to: .zero) { [unowned self] _ in
            self.play()
        }
    }
    
    func setVolume(_ volume: Float) {
        player?.volume = volume
    }
    
    func setPlaybackRate(_ rate: Float) {
        guard let player = player else { return }
        player.rate = rate
    }
    
    func seek(position: TimeInterval) {
        guard let player = player else { return }
        delegate?.willSeek(audioPlayer: self)
        let to = CMTime(seconds: position, preferredTimescale: player.currentTime().timescale)
        player.seek(to: to, completionHandler: { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.didSeek(audioPlayer: self)
        })
    }
    
    @objc
    func onPlayEnded(_ notification: Notification) {
        guard let playerItem = playerItem,
              let object = notification.object as? AVPlayerItem,
              object == playerItem else { return }
        delegate?.didEndPlay(audioPlayer: self)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.status) {
            if let statusNumber = change?[.newKey] as? Int, let status = AVPlayer.Status(rawValue: statusNumber) {
                if status == .readyToPlay {
                    if let playerItem = playerItem {
                        let duration = playerItem.asset.duration.seconds
                        delegate?.audioPlayer(self, canplay: duration)
                    }
                }
            }
        }
    }
}
