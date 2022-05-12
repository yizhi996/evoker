//
//  NZVideoPlayer.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation

class NZVideoPlayer: NZPlayer {
    
    var loadedDataHandler: ((TimeInterval, CGFloat, CGFloat) -> Void)?
    
    var fullscreenChangeHandler: NZEmptyBlock?
    
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

//MARK: NZSubscribeKey
extension NZVideoPlayer {
    
    public static let onLoadedDataSubscribeKey = NZSubscribeKey("MODULE_VIDEO_ON_LOADED_DATA")
    
    public static let onPlaySubscribeKey = NZSubscribeKey("MODULE_VIDEO_ON_PLAY")
    
    public static let onPauseSubscribeKey = NZSubscribeKey("MODULE_VIDEO_ON_PAUSE")
    
    public static let onErrorSubscribeKey = NZSubscribeKey("MODULE_VIDEO_ON_ERROR")
    
    public static let timeUpdateSubscribeKey = NZSubscribeKey("MODULE_VIDEO_TIME_UPDATE")
    
    public static let bufferUpdateSubscribeKey = NZSubscribeKey("MODULE_VIDEO_BUFFER_UPDATE")
    
    public static let endedSubscribeKey = NZSubscribeKey("MODULE_VIDEO_ON_ENDED")
    
    public static let fullscreenChangeSubscribeKey = NZSubscribeKey("MODULE_VIDEO_FULLSCREEN_CHANGE")
    
    public static let seekCompleteSubscribeKey = NZSubscribeKey("MODULE_VIDEO_SEEK_COMPLETE")
    
    public static let waitingSubscribeKey = NZSubscribeKey("MODULE_VIDEO_WAITING")
}
