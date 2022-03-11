//
//  NZAudioModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZAudioModule: NZModule {
    
    typealias PageId = Int
    
    typealias AudioId = Int
    
    static var name: String {
        return "com.nozthdev.module.audio"
    }
    
    static var apis: [String : NZAPI] {
        var apis: [String: NZAPI] = [:]
        NZAudioAPI.allCases.forEach { apis[$0.rawValue] = $0 }
        return apis
    }
    
    weak var appService: NZAppService?
    
    lazy var players: DoubleLevelDictionary<PageId, AudioId, NZAudioPlayer> = DoubleLevelDictionary()
    
    required init(appService: NZAppService) {
        self.appService = appService
    }
    
    func willExitPage(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.stop() }
        players.remove(page.pageId)
    }
    
}
