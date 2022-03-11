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
    
    lazy var players: DoubleLevelDictionary<PageId, VideoId, NZVideoPlayerView> = DoubleLevelDictionary()
    
    required init(appService: NZAppService) {
        
    }
    
    func willExitPage(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.stop() }
        players.remove(page.pageId)
    }
}
