//
//  VideoModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class VideoModule: Module {
    
    typealias PageId = Int
    
    typealias VideoId = Int
    
    static var name: String {
        return "com.evokerdev.module.video"
    }
    
    static var apis: [String : API] {
        var result: [String : API] = [:]
        VideoAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    lazy var playerViews: DoubleLevelDictionary<PageId, VideoId, VideoPlayerView> = DoubleLevelDictionary()
    
    required init(appService: AppService) {
        
    }
    
    func onShow(_ page: Page) {
        playerViews.get(page.pageId)?.values.forEach { playerView in
            playerView.player.didBecomeActive()
        }
    }
    
    func onHide(_ page: Page) {
        playerViews.get(page.pageId)?.values.forEach { playerView in
            playerView.player.willResignActive()
        }
    }
    
    func onUnload(_ page: Page) {
        playerViews.get(page.pageId)?.forEach { (_, playerView) in
            playerView.stop()
            playerView.removeFromSuperview()
        }
        playerViews.remove(page.pageId)
    }
    
}
