//
//  WebSocketAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum WebSocketAPI: String, CaseIterableAPI {
    
    case operateWebSocket
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        switch self {
        case .operateWebSocket:
            operateWebSocket(appService: appService, bridge: bridge, args: args)
        }
    }
    
    private func operateWebSocket(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        struct Params: Decodable {
            let socketTaskId: Int
            let method: Method
            let data: Data
            
            enum Method: String, Decodable {
                case connect
                case close
                case send
            }
            
            enum Data: Decodable {
                case connect(ConnectData)
                case close(CloseData)
                case send(SendData)
                case unknown
                
                struct ConnectData: Decodable {
                    let url: String
                    let header: [String: String]
                    let protocols: [String]?
                    let timeout: TimeInterval
                }
                
                struct CloseData: Decodable {
                    let code: Int
                    let reason: String?
                }
                
                struct SendData: Decodable {
                    let text: String?
                    let data: Foundation.Data?
                }
                
                init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let data = try? container.decode(ConnectData.self) {
                        self = .connect(data)
                        return
                    }
                    if let data = try? container.decode(CloseData.self) {
                        self = .close(data)
                        return
                    }
                    if let data = try? container.decode(SendData.self) {
                        self = .send(data)
                        return
                    }
                    self = .unknown
                }
            }
        }

        guard let params: Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let module: WebSocketModule = appService.getModule() else {
            let error = EKError.bridgeFailed(reason: .moduleNotFound(WebSocketModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .connect:
            if case .connect(let data) = params.data {
                if let url = URL(string: data.url) {
                    let ws = WebSocketTask(url: url, headers: data.header, protocols: data.protocols, timeout: data.timeout)
                    ws.delegate = module
                    ws.socketTaskId = params.socketTaskId
                    ws.connect()
                    module.webSockets[params.socketTaskId] = ws
                    bridge.invokeCallbackSuccess(args: args)
                } else {
                    bridge.invokeCallbackFail(args: args, error: EKError.urlInvalidated(data.url))
                }
            }
        case .close:
            if case .close(let data) = params.data {
                if let ws = module.webSockets[params.socketTaskId] {
                    ws.disconnect(code: data.code, reason: data.reason)
                    bridge.invokeCallbackSuccess(args: args)
                } else {
                    
                }
            }
        case .send:
            if case .send(let data) = params.data {
                if let ws = module.webSockets[params.socketTaskId] {
                    do {
                        if let text = data.text {
                            try ws.send(text)
                        } else if let data = data.data {
                            try ws.send(data)
                        }
                        bridge.invokeCallbackSuccess(args: args)
                    } catch {
                        bridge.invokeCallbackFail(args: args, error: EKError.custom(error.localizedDescription))
                    }
                } else {
                    
                }
            }
        }
    }
}
