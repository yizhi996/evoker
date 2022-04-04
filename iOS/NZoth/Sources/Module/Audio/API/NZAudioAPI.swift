//
//  NZAudioAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZAudioAPI: String, NZBuiltInAPI {
    
    case operateInnerAudioContext
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .operateInnerAudioContext:
                operateInnerAudioContext(args: args, bridge: bridge)
            }
        }
    }
    
    private func operateInnerAudioContext(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        struct Params: Decodable {
            let audioId: Int
            let method: Method
            let data: [String: Any]
            
            enum CodingKeys: String, CodingKey {
                case audioId, method, data
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                audioId = try container.decode(Int.self, forKey: .audioId)
                method = try container.decode(Method.self, forKey: .method)
                data = try container.decode([String: Any].self, forKey: .data)
            }
        }
        
        enum Method: String, Decodable {
            case play
            case pause
            case stop
            case seek
            case setVolume
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = appService.currentPage as? NZWebPage else {
            let error = NZError.bridgeFailed(reason: .appServiceNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let audioModule: NZAudioModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZAudioModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .play:
            if let player = audioModule.players.get(page.pageId, page.pageId) {
                player.play()
            } else if var params: NZAudioPlayer.Params = params.data.toModel() {
                if let src = params.src {
                    params._url = FilePath.nzFilePathToRealFilePath(appId: appService.appId,
                                                                    userId: NZEngine.shared.userId,
                                                                    filePath: src) ?? URL(string: src)
                }
                let player = NZAudioPlayer(params: params)
                audioModule.players.set(page.pageId, page.pageId, value: player)
                player.play()
            } else {
                bridge.invokeCallbackFail(args: args, error: .custom("create audio player failed"))
            }
        case .pause:
            guard let player = audioModule.players.get(page.pageId, page.pageId) else { break }
            player.pause()
        case .stop:
            guard let player = audioModule.players.get(page.pageId, page.pageId) else { break }
            player.stop()
        case .seek:
            guard let player = audioModule.players.get(page.pageId, page.pageId) else { break }
            player.stop()
        case .setVolume:
            guard let player = audioModule.players.get(page.pageId, page.pageId) else { break }
            if let volume = params.data["volume"] as? Float {
                player.setVolume(volume)
            }
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
