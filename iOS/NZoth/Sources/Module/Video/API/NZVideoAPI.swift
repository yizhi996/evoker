//
//  NZVideoAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZVideoAPI: String, NZBuiltInAPI {
        
    case insertVideoPlayer
    case operateVideoPlayer
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .insertVideoPlayer:
                insertVideoPlayer(args: args, bridge: bridge)
            case .operateVideoPlayer:
                operateVideoPlayer(args: args, bridge: bridge)
            }
        }
    }
    
    private func insertVideoPlayer(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard var params: NZVideoPlayerParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let videoModule: NZVideoModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZVideoModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        params._url = FilePath.nzFilePathToRealFilePath(appId: appService.appId,
                                                        userId: NZEngine.shared.userId,
                                                        filePath: params.url) ?? URL(string: params.url)
        
        let playerView = NZVideoPlayerView(params: params)
        playerView.forceRotateScreen = { value in
            webView.page?.forceRotateScreen = value
        }
        playerView.playHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.onPlaySubscribeKey, data: message)
        }
        playerView.pauseHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.onPauseSubscribeKey, data: message)
        }
        playerView.endedHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.endedSubscribeKey, data: message)
        }
        playerView.timeUpdateHandler = { currentTime, duration in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "currentTime": currentTime,
                                          "duration": duration]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.timeUpdateSubscribeKey, data: message)
        }
        playerView.progressHandler = { bufferTime in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "bufferTime": bufferTime]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.bufferUpdateSubscribeKey, data: message)
        }
        playerView.errorHandler = { error in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "error": error]
            webView.bridge.subscribeHandler(method: NZVideoPlayerView.onErrorSubscribeKey, data: message)
        }
        
        container.addSubview(playerView)
        playerView.autoPinEdgesToSuperviewEdges()
        
        videoModule.players.set(page.pageId, params.videoPlayerId, value: playerView)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateVideoPlayer(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let videoPlayerId: Int
            let method: Method
            let data: [String: Any]
            
            enum CodingKeys: String, CodingKey {
                case videoPlayerId, method, data
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                videoPlayerId = try container.decode(Int.self, forKey: .videoPlayerId)
                method = try container.decode(Method.self, forKey: .method)
                data = try container.decode([String: Any].self, forKey: .data)
            }
        }
        
        enum Method: String, Decodable {
            case play
            case pause
            case remove
            case muted
            case enterFullscreen
            case changeURL
        }
        
        guard let appService = bridge.appService else { return }

        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let videoModule: NZVideoModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZVideoModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let videoPlayer = videoModule.players.get(page.pageId, params.videoPlayerId) else {
            let error = NZError.bridgeFailed(reason: .videoPlayerIdNotFound(params.videoPlayerId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .play:
            videoPlayer.play(params.data)
        case .pause:
            videoPlayer.pause()
        case .remove:
            videoPlayer.stop()
            videoModule.players.remove(page.pageId, params.videoPlayerId)
        case .muted:
            guard let muted = params.data["muted"] as? Bool else { break }
            videoPlayer.muted = muted
        case .enterFullscreen:
            guard let enterFullscreen = params.data["enterFullscreen"] as? Bool else { break }
            if enterFullscreen {
                videoPlayer.enterFullscreen()
            } else {
                videoPlayer.quiteFullscreen()
            }
        case .changeURL:
            guard let url = params.data["url"] as? String else { break }
            videoPlayer.url = FilePath.nzFilePathToRealFilePath(appId: appService.appId,
                                                                userId: NZEngine.shared.userId,
                                                                filePath: url) ?? URL(string: url)
        }
       
        bridge.invokeCallbackSuccess(args: args)
    }
}
