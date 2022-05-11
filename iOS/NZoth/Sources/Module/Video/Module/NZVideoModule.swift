//
//  NZVideoModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZVideoModule: NZModule {
    
    typealias PageId = Int
    
    typealias VideoId = Int
    
    static var name: String {
        return "com.nozthdev.module.video"
    }
    
    static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZVideoAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    lazy var playerViews: DoubleLevelDictionary<PageId, VideoId, NZVideoPlayerView> = DoubleLevelDictionary()
    
    required init(appService: NZAppService) {
        
    }
    
    func onShow(_ page: NZPage) {
        playerViews.get(page.pageId)?.values.forEach { playerView in
            if playerView.player.needResume {
                playerView.play()
                playerView.player.needResume = false
            }
        }
    }
    
    func onHide(_ page: NZPage) {
        playerViews.get(page.pageId)?.values.forEach { playerView in
            if playerView.player.isPlaying {
                playerView.pause()
                playerView.player.needResume = true
            }
        }
    }
    
    func onUnload(_ page: NZPage) {
        playerViews.get(page.pageId)?.forEach { (_, playerView) in
            playerView.stop()
            playerView.removeFromSuperview()
        }
        playerViews.remove(page.pageId)
    }
    
}
