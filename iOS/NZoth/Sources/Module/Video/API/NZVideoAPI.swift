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
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertVideoPlayer:
                insertVideoPlayer(appService: appService, bridge: bridge, args: args)
            case .operateVideoPlayer:
                operateVideoPlayer(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertVideoPlayer(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
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
        
        guard var params: NZVideoPlayerViewParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: NZVideoModule = appService.getModule() else {
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
        playerView.player.loadedDataHandler = { duration, width, height in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "duration": duration,
                                          "width": width,
                                          "height": height]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.onLoadedDataSubscribeKey, data: message)
        }
        playerView.player.playHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.onPlaySubscribeKey, data: message)
        }
        playerView.player.pauseHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.onPauseSubscribeKey, data: message)
        }
        playerView.player.endedHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.endedSubscribeKey, data: message)
        }
        playerView.player.timeUpdateHandler = { currentTime in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "currentTime": currentTime]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.timeUpdateSubscribeKey, data: message)
        }
        playerView.player.bufferUpdateHandler = { bufferTime in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "bufferTime": bufferTime]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.bufferUpdateSubscribeKey, data: message)
        }
        playerView.player.playFailedHandler = { error in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "error": error]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.onErrorSubscribeKey, data: message)
        }
        playerView.player.fullscreenChangeHandler = {
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.fullscreenChangeSubscribeKey, data: message)
        }
        playerView.player.seekCompletionHandler = { position in
            let message: [String: Any] = ["videoPlayerId": params.videoPlayerId,
                                          "position": position]
            webView.bridge.subscribeHandler(method: NZVideoPlayer.seekCompleteSubscribeKey, data: message)
        }
        container.addSubview(playerView)
        playerView.autoPinEdgesToSuperviewEdges()
        
        module.playerViews.set(page.pageId, params.videoPlayerId, value: playerView)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateVideoPlayer(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let videoPlayerId: Int
            let method: Method
            let data: Data
            
            enum Method: String, Decodable {
                case play
                case pause
                case remove
                case mute
                case fullscreen
                case changeURL
                case seek
                case replay
            }
            
            enum Data: Decodable {
                case mute(MuteData)
                case fullscreen(FullscreenData)
                case seek(SeekData)
                case unknown
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let data = try? container.decode(MuteData.self) {
                        self = .mute(data)
                        return
                    }
                    if let data = try? container.decode(FullscreenData.self) {
                        self = .fullscreen(data)
                        return
                    }
                    if let data = try? container.decode(SeekData.self) {
                        self = .seek(data)
                        return
                    }
                    self = .unknown
                }
                
                struct MuteData: Decodable {
                    let muted: Bool
                }
                
                struct FullscreenData: Decodable {
                    let enter: Bool
                    let direction: Int
                }
                
                struct SeekData: Decodable {
                    let position: TimeInterval
                }
            }
        }

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
        
        guard let module: NZVideoModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZVideoModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let playerView = module.playerViews.get(page.pageId, params.videoPlayerId) else {
            let error = NZError.bridgeFailed(reason: .videoPlayerIdNotFound(params.videoPlayerId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .play:
            playerView.play()
        case .pause:
            playerView.pause()
        case .remove:
            playerView.stop()
            module.playerViews.remove(page.pageId, params.videoPlayerId)
        case .mute:
            if case .mute(let data) = params.data {
                playerView.player.isMuted = data.muted
            }
        case .fullscreen:
            if case .fullscreen(let data) = params.data {
                if data.enter {
                    var orientation: UIInterfaceOrientation
                    if data.direction == 0 {
                        orientation = .portrait
                    } else if data.direction == -90 {
                        orientation = .landscapeRight
                    } else if data.direction == 90 {
                        orientation = .landscapeLeft
                    } else {
                        orientation = .landscapeRight
                    }
                    playerView.enterFullscreen(orientation: orientation)
                } else {
                    playerView.quiteFullscreen()
                }
            }
        case .changeURL:
            break
        case .seek:
            if case .seek(let data) = params.data {
                playerView.seek(position: data.position)
            }
        case .replay:
            playerView.player.replay()
        }
       
        bridge.invokeCallbackSuccess(args: args)
    }
}
