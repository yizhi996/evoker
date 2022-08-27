//
//  CryptoAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import CryptoSwift
import SwiftyRSA

enum CryptoAPI: String, CaseIterableAPI {
    
    case rsa
    case getRandomValues
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.global().async {
            switch self {
            case .rsa:
                rsa(appService: appService, bridge: bridge, args: args)
            case .getRandomValues:
                getRandomValues(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func rsa(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let action = params["action"] as? String else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("action"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let text = params["text"] as? String, !text.isEmpty else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("text"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if action == "encrypt" {
            do {
                let publicKey = try PublicKey(base64Encoded: key)
                let clear = try ClearMessage(string: text, using: .utf8)
                let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
                bridge.invokeCallbackSuccess(args: args, result: ["text": encrypted.base64String])
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else if action == "decrypt" {
            do {
                let privateKey = try PrivateKey(base64Encoded: key)
                let encrypted = try EncryptedMessage(base64Encoded: text)
                let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
                let string = try clear.string(encoding: .utf8)
                bridge.invokeCallbackSuccess(args: args, result: ["text": string])
            } catch {
                let error = EKError.bridgeFailed(reason: .custom(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        }
    }
    
    private func getRandomValues(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let length = params["length"] as? Int else {
            let error = EKError.bridgeFailed(reason: .fieldRequired("length"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var bytes = [Int8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            let data = Data(bytes: bytes, count: bytes.count)
            let arrayBuffer = data.toJSArrayBuffer(context: appService.context.context)
            let id = appService.context.arrayBufferRegister.set(arrayBuffer)
            bridge.invokeCallbackSuccess(args: args, result: [ArrayBufferRegister.Key: id])
        } else {
            bridge.invokeCallbackFail(args: args, error: .bridgeFailed(reason: .custom("")))
        }
    }

}
