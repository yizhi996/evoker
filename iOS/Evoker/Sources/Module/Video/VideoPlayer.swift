//
//  VideoPlayer.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation

class VideoPlayer: Player {
    
    var loadedDataHandler: ((TimeInterval, CGFloat, CGFloat) -> Void)?
    
    var fullscreenChangeHandler: EmptyBlock?
    
    override init() {
        super.init()
        
        readyToPlayHandler = { [unowned self] duration in
            var width: CGFloat = 0
            var height: CGFloat = 0
            if let asset = self.player?.currentItem?.asset, let track = asset.tracks(withMediaType: .video).first {
                let size = track.naturalSize.applying(track.preferredTransform)
                width = size.width
                height = size.height
            }
            self.loadedDataHandler?(duration, width, height)
        }
    }
}

//MARK: SubscribeKey
extension VideoPlayer {
    
    public static let onLoadedDataSubscribeKey = SubscribeKey("MODULE_VIDEO_ON_LOADED_DATA")
    
    public static let onPlaySubscribeKey = SubscribeKey("MODULE_VIDEO_ON_PLAY")
    
    public static let onPauseSubscribeKey = SubscribeKey("MODULE_VIDEO_ON_PAUSE")
    
    public static let onErrorSubscribeKey = SubscribeKey("MODULE_VIDEO_ON_ERROR")
    
    public static let timeUpdateSubscribeKey = SubscribeKey("MODULE_VIDEO_TIME_UPDATE")
    
    public static let bufferUpdateSubscribeKey = SubscribeKey("MODULE_VIDEO_BUFFER_UPDATE")
    
    public static let endedSubscribeKey = SubscribeKey("MODULE_VIDEO_ON_ENDED")
    
    public static let fullscreenChangeSubscribeKey = SubscribeKey("MODULE_VIDEO_FULLSCREEN_CHANGE")
    
    public static let seekCompleteSubscribeKey = SubscribeKey("MODULE_VIDEO_SEEK_COMPLETE")
    
    public static let waitingSubscribeKey = SubscribeKey("MODULE_VIDEO_WAITING")
}
