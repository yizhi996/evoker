//
//  VideoPlayerView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import Photos
import KTVHTTPCache
import PureLayout
import AVFoundation

public struct VideoPlayerViewParams: Codable  {
    
    let parentId: String
    
    let videoPlayerId: Int
    
    var url: String
    
    var objectFit: ObjectFit
    
    var muted: Bool
    
    var loop: Bool
    
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

public class VideoPlayerView: UIView {
    
    public override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
    
    var forceRotateScreen: BoolBlock?
    
    var player = VideoPlayer()
    
    var params: VideoPlayerViewParams!
    
    let playerId: Int
    
    public init(params: VideoPlayerViewParams) {
        self.params = params
        playerId = params.videoPlayerId
        super.init(frame: .zero)
        
        backgroundColor = .black
        
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
    
    func setURL(_ url: URL) {
        params._url = url
        player.setURL(url)
        playerLayer.player = player.player
        playerLayer.videoGravity = params.objectFit.toNatively()
        player.isMuted = params.muted
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

extension VideoPlayerView {
    
    func enterFullscreen(orientation: UIInterfaceOrientation) {
        if orientation == .portrait {
            NotificationCenter.default.post(name: VideoPlayerView.willEnterFullscreenVideoPlayer, object: nil)
        } else {
            forceRotateScreen?(true)
            UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
            UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
            NotificationCenter.default.post(name: VideoPlayerView.willEnterFullscreenVideoPlayer, object: nil)
            forceRotateScreen?(false)
        }   
    }
    
    func quiteFullscreen() {
        forceRotateScreen?(true)
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        NotificationCenter.default.post(name: VideoPlayerView.willQuitFullscreenVideoPlayer, object: nil)
        forceRotateScreen?(false)
    }
    
}

extension VideoPlayerView {
    
    public static let willEnterFullscreenVideoPlayer = Notification.Name("willEnterFullscreenVideoPlayer")
    
    public static let willQuitFullscreenVideoPlayer = Notification.Name("willQuitFullscreenVideoPlayer")
}
