//
//  Player.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation
import KTVHTTPCache
import UIKit

class Player: NSObject {
    
    enum PlayStatus {
        
        case none
        
        case playing
        
        case pause
        
        case stoped
        
        case failed
    }
    
    var readyToPlayHandler: DoubleBlock?
    
    var playFailedHandler: StringBlock?
    
    var playHandler: EmptyBlock?
    
    var pauseHandler: EmptyBlock?
    
    var stopHandler: EmptyBlock?
    
    var endedHandler: EmptyBlock?
    
    var timeUpdateHandler: ((TimeInterval) -> Void)?
    
    var bufferUpdateHandler: ((TimeInterval) -> Void)?
    
    var seekingHandler: EmptyBlock?
    
    var seekCompletionHandler: CGFloatBlock?
    
    var waitingHandler: BoolBlock?
    
    var currentPlayURL: URL?
    
    var player: AVPlayer?
    
    var playerItem: AVPlayerItem?
    
    var timeUpdateObserver: Any?
    
    var isPlaying = false
    
    var playStatus: PlayStatus = .none {
        didSet {
            switch playStatus {
            case .playing:
                playHandler?()
            case .pause:
                pauseHandler?()
            case .stoped:
                stopHandler?()
            default:
                break
            }
        }
    }
    
    var isMuted: Bool = false {
        didSet {
            player?.isMuted = isMuted
        }
    }
    
    var playbackRate: Float = 1.0
    
    var needResume = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willResignActive),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    deinit {
        removeObserver()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func willResignActive() {
        if isPlaying {
            pause()
            needResume = true
        }
    }
    
    @objc func didBecomeActive() {
        if needResume {
            play()
            needResume = false
        }
    }
    
    func removeObserver() {
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty))
            playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp))
            NotificationCenter.default.removeObserver(self,
                                                      name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                      object: playerItem)
        }
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
                Logger.error("KTVHTTPCache Start failed: \(error)")
            }
        }
        
        reset()
        
        if let proxyURL = KTVHTTPCache.proxyURL(withOriginalURL: url) {
            playerItem = AVPlayerItem(url: proxyURL)
            player = AVPlayer(playerItem: playerItem)
            
            playerItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: .new, context: nil)
            playerItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: .new, context:
                                        nil)
            playerItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: .new, context: nil)
            playerItem!.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: .new, context: nil)
            let interval = CMTime(seconds: 0.25, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeUpdateObserver = player!.addPeriodicTimeObserver(forInterval: interval, queue: nil) { [weak self] time in
                guard let self = self else { return }
                self.timeUpdateHandler?(time.seconds)
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
        player.isMuted = isMuted
        player.rate = playbackRate
        playStatus = .playing
        isPlaying = true
    }
    
    func pause() {
        guard let player = player, let playerItem = playerItem else { return }
        player.pause()
        playerItem.cancelPendingSeeks()
        playerItem.asset.cancelLoading()
        playStatus = .pause
        isPlaying = false
    }
    
    func stop() {
        guard let player = player, let playerItem = playerItem else { return }
        playerItem.cancelPendingSeeks()
        playerItem.asset.cancelLoading()
        player.pause()
        player.seek(to: .zero)
        playStatus = .stoped
        isPlaying = false
    }
    
    func reset() {
        stop()
        player?.replaceCurrentItem(with: nil)
        timeUpdateObserver = nil
        removeObserver()
        playerItem = nil
        player = nil
        currentPlayURL = nil
        isPlaying = false
        playStatus = .none
    }
    
    func destroy() {
        reset()
        
        playHandler = nil
        stopHandler = nil
        endedHandler = nil
        pauseHandler = nil
        seekingHandler = nil
        waitingHandler = nil
        playFailedHandler = nil
        timeUpdateHandler = nil
        bufferUpdateHandler = nil
        seekCompletionHandler = nil
        readyToPlayHandler = nil
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
        playbackRate = rate
        if isPlaying {
            player?.rate = rate
        }
    }
    
    func seek(position: TimeInterval) {
        guard let player = player else { return }
        seekingHandler?()
        let to = CMTime(seconds: position, preferredTimescale: player.currentTime().timescale)
        player.seek(to: to, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let self = self else { return }
            self.seekCompletionHandler?(position)
        }
    }
    
    @objc
    func onPlayEnded(_ notification: Notification) {
        guard let playerItem = playerItem,
              let object = notification.object as? AVPlayerItem,
              object == playerItem else { return }
        endedHandler?()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {
            if let statusValue = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: statusValue) {
                if status == .readyToPlay {
                    if let playerItem = playerItem {
                        let duration = playerItem.asset.duration.seconds
                        readyToPlayHandler?(duration)
                    }
                } else if status == .failed {
                    playStatus = .failed
                    if let error = player?.currentItem?.error {
                        playFailedHandler?(error.localizedDescription)
                    } else {
                        playFailedHandler?("player play failed")
                    }
                }
            }
        } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            let timeRange = playerItem!.loadedTimeRanges.first as! CMTimeRange
            let duration = CMTimeGetSeconds(timeRange.end)
            bufferUpdateHandler?(duration)
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackBufferEmpty) {
            waitingHandler?(true)
        } else if keyPath == #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp) {
            if playerItem!.isPlaybackLikelyToKeepUp {
                waitingHandler?(false)
            }
        }
    }
}
