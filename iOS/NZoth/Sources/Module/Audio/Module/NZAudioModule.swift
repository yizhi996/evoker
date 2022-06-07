//
//  NZAudioModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation

class NZAudioModule: NSObject, NZModule {
    
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
    
    var mixWithOther = true
    
    var obeyMuteSwitch = true
    
    var speakerOn = true
    
    weak var appService: NZAppService?
    
    lazy var players: DoubleLevelDictionary<PageId, AudioId, NZAudioPlayer> = DoubleLevelDictionary()
    
    required init(appService: NZAppService) {
        super.init()
        self.appService = appService
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }

        switch type {
        case .began:
            players.all().forEach { $0.pause() }
            appService?.bridge.subscribeHandler(method: NZAppService.onAudioInterruptionBeginSubscribeKey, data: [:])
        case .ended:
            appService?.bridge.subscribeHandler(method: NZAppService.onAudioInterruptionEndSubscribeKey, data: [:])
        default:
            break
        }
    }
    
    func setAudioCategory() {
        let session = AVAudioSession.sharedInstance()
        let options: AVAudioSession.CategoryOptions = mixWithOther ? .mixWithOthers : []
        let cateory: AVAudioSession.Category
        if speakerOn {
            if obeyMuteSwitch {
                cateory = .playback
            } else {
                cateory = .soloAmbient
            }
        } else {
            cateory = .playAndRecord
        }
        try? session.setCategory(cateory, mode: .default, options: options)
    }
    
    func onShow(_ service: NZAppService) {
        setAudioCategory()
    }
    
    func onShow(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.didBecomeActive() }
    }
    
    func onHide(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.willResignActive() }
    }
    
    func onUnload(_ page: NZPage) {
        players.get(page.pageId)?.values.forEach { $0.destroy() }
        players.remove(page.pageId)
    }

}
