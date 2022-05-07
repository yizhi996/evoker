//
//  NZVideoPlayerView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Photos
import ZFPlayer
import KTVHTTPCache
import PureLayout

public struct NZVideoPlayerParams: Codable  {
    
    let parentId: String
    
    let videoPlayerId: Int
    
    let url: String
    
    let objectFit: ObjectFit
    
    let muted: Bool
    
    let loop: Bool
    
    var _url: URL?
    
    enum ObjectFit: String, Codable {
        case contain
        case fill
        case cover
    }
}

open class NZVideoPlayerView: UIView {
        
    var playHandler: NZEmptyBlock?
    
    var pauseHandler: NZEmptyBlock?
    
    var endedHandler: NZEmptyBlock?
    
    var timeUpdateHandler: ((TimeInterval, TimeInterval) -> Void)?
    
    var fullscreenChangeHandler: ((Bool, CGFloat) -> Void)?
    
    var waitingHandler: NZEmptyBlock?
    
    var errorHandler: NZStringBlock?
    
    var progressHandler: NZCGFloatBlock?
    
    var loadedMetadataHandler: ((CGFloat, CGFloat, TimeInterval) -> Void)?
    
    var seekCompletionHandler: NZCGFloatBlock?
    
    var forceRotateScreen: NZBoolBlock?
    
    var muted: Bool {
        get {
            return player.currentPlayerManager.isMuted
        } set {
            player.currentPlayerManager.isMuted = newValue
        }
    }
    
    var isPlaying = false
    
    var needResume = false
    
    private let throttler = Throttler(seconds: 0.25)
    
    lazy var player: ZFPlayerController = {
        let manager = ZFAVPlayerManager()
        manager.shouldAutoPlay = false
        manager.isMuted = params.muted
        
        let player = ZFPlayerController(playerManager: manager, containerView: self)
        player.orientationObserver.supportInterfaceOrientation = .portrait
        player.playerPrepareToPlay = { _, _ in
            print("playerPrepareToPlay")
        }
        player.playerReadyToPlay = { _, _ in
            print("playerReadyToPlay")
        }
        player.playerPlayFailed = { [unowned self] _, error in
            self.errorHandler?("\(error)")
        }
        player.playerDidToEnd = { [unowned self] _ in
            self.endedHandler?()
            if self.params.loop {
                player.currentPlayerManager.replay()
            }
        }
        
        // 播放进度
        player.playerPlayTimeChanged = { [unowned self] _, currentTime, duration in
            guard let timeUpdateHandler =  self.timeUpdateHandler else { return }
            self.throttler.invoke { timeUpdateHandler(currentTime, duration) }
        }
        // 加载进度
        player.playerBufferTimeChanged = { [unowned self] _, bufferTime in
            self.progressHandler?(bufferTime)
        }
        // 加载状态
        player.playerLoadStateChanged = { [unowned self] _, state in
            switch state {
            case .prepare:
                print("load prepare")
            case .playable:
                print("load playable")
            case .playthroughOK:
                print("load playthroughOK")
            case .stalled:
                print("load stalled")
            default:
                break
            }
        }
        // 播放状态
        player.playerPlayStateChanged = { [unowned self] _, state in
            switch state {
            case .playStatePlaying:
                self.playHandler?()
            case .playStatePaused:
                self.pauseHandler?()
            case .playStatePlayFailed:
                print("playStatePlayFailed")
            case .playStatePlayStopped:
                print("playStatePlayStopped")
            default:
                break
            }
        }
        
        return player
    }()
    
    var params: NZVideoPlayerParams!
    
    var url: URL? {
        get {
            return player.currentPlayerManager.assetURL
        } set {
            if let newValue = newValue {
                if !KTVHTTPCache.proxyIsRunning() {
                    do {
                        try KTVHTTPCache.proxyStart()
                    } catch {
                        NZLogger.error("KTVHTTPCache Start failed: \(error)")
                    }
                }
                if let assetURL = KTVHTTPCache.proxyURL(withOriginalURL: newValue) {
                    player.currentPlayerManager.assetURL = assetURL
                } else {
                    player.currentPlayerManager.assetURL = newValue
                }
            } else {
                if player.currentPlayerManager.isPlaying {
                    player.stop()
                }
            }
        }
    }
    
    let playerId: Int
    
    public init(params: NZVideoPlayerParams) {
        self.params = params
        playerId = params.videoPlayerId
        super.init(frame: .zero)
        
        url = params._url
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(NSStringFromClass(Self.self)) deinit")
    }
    
    func play() {
        if url != nil {
            player.currentPlayerManager.play()
            isPlaying = true
        }
    }
    
    func pause() {
        player.currentPlayerManager.pause()
        isPlaying = false
    }
    
    func stop() {
        player.currentPlayerManager.stop()
        isPlaying = false
    }
    
    func seek(position: TimeInterval) {
        player.currentPlayerManager.seek(toTime: position) { [unowned self] _ in
            self.seekCompletionHandler?(position)
        }
    }
}

extension NZVideoPlayerView {
    
    func enterFullscreen() {
        forceRotateScreen?(true)
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        NotificationCenter.default.post(name: NZVideoPlayerView.willEnterFullscreenVideoPlayer, object: nil)
        forceRotateScreen?(false)
    }
    
    func quiteFullscreen() {
        forceRotateScreen?(true)
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        NotificationCenter.default.post(name: NZVideoPlayerView.willQuitFullscreenVideoPlayer, object: nil)
        forceRotateScreen?(false)
    }
    
}

//MARK: NZSubscribeKey
extension NZVideoPlayerView {
    
    public static let onPlaySubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_PLAY")
    
    public static let onPauseSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_PAUSE")
    
    public static let onErrorSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_ERROR")
    
    public static let timeUpdateSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_TIME_UPDATE")
    
    public static let bufferUpdateSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE")
    
    public static let endedSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ENDED")
    
}

extension NZVideoPlayerView {
    
    public static let willEnterFullscreenVideoPlayer = Notification.Name("willEnterFullscreenVideoPlayer")
    
    public static let willQuitFullscreenVideoPlayer = Notification.Name("willQuitFullscreenVideoPlayer")
}
