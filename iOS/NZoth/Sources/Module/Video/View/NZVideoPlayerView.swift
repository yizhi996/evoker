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
import KTVHTTPCache
import PureLayout
import AVFoundation

public struct NZVideoPlayerViewParams: Codable  {
    
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
        
        func toNatively() -> AVLayerVideoGravity {
            switch self {
            case .contain:
                return .resizeAspect
            case .cover:
                return .resize
            case .fill:
                return .resizeAspectFill
            }
        }
    }
}

public class NZVideoPlayerView: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var loadedDataHandler: ((TimeInterval, CGFloat, CGFloat) -> Void)?
    
    var forceRotateScreen: NZBoolBlock?
    
    var player = NZVideoPlayer()
    
    var params: NZVideoPlayerViewParams!
    
    let playerId: Int
    
    public init(params: NZVideoPlayerViewParams) {
        self.params = params
        playerId = params.videoPlayerId
        super.init(frame: .zero)
        
        backgroundColor = .black
        
        player.readyToPlayHandler = { [unowned self] duration in
            var width: CGFloat = 0
            var height: CGFloat = 0
            if let asset = self.player.player?.currentItem?.asset, let track = asset.tracks(withMediaType: .video).first {
                let size = track.naturalSize.applying(track.preferredTransform)
                width = size.width
                height = size.height
            }
            self.loadedDataHandler?(duration, width, height)
        }
        
        if let url = params._url {
            player.setURL(url)
        }
        
        playerLayer.player = player.player
        playerLayer.videoGravity = params.objectFit.toNatively()
        player.isMuted = params.muted
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(Self.self) deinit")
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    func seek(position: TimeInterval) {
        player.seek(position: position)
    }
}

extension NZVideoPlayerView {
    
    func enterFullscreen(orientation: UIInterfaceOrientation) {
        if orientation == .portrait {
            NotificationCenter.default.post(name: NZVideoPlayerView.willEnterFullscreenVideoPlayer, object: nil)
        } else {
            forceRotateScreen?(true)
            UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            NotificationCenter.default.post(name: NZVideoPlayerView.willEnterFullscreenVideoPlayer, object: nil)
            forceRotateScreen?(false)
        }   
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
    
    public static let onLoadedDataSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_LOADED_DATA")
    
    public static let onPlaySubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_PLAY")
    
    public static let onPauseSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_PAUSE")
    
    public static let onErrorSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_ERROR")
    
    public static let timeUpdateSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_TIME_UPDATE")
    
    public static let bufferUpdateSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_BUFFER_UPDATE")
    
    public static let endedSubscribeKey = NZSubscribeKey("WEBVIEW_VIDEO_PLAYER_ON_ENDED")
    
}

extension NZVideoPlayerView {
    
    public static let willEnterFullscreenVideoPlayer = Notification.Name("willEnterFullscreenVideoPlayer")
    
    public static let willQuitFullscreenVideoPlayer = Notification.Name("willQuitFullscreenVideoPlayer")
}
