//
//  NZCryptoAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import CryptoSwift

enum NZCryptoAPI: String, NZBuiltInAPI {
    
    case rsa
    case getRandomValues
    
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.global().async {
            switch self {
            case .rsa:
                rsa(args: args, bridge: bridge)
            case .getRandomValues:
                getRandomValues(args:args, bridge: bridge)
            }
        }
    }
    
    private func rsa(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let action = params["action"] as? String, !action.isEmpty, ["encrypt", "decrypt"].contains(action) else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("action"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let key = params["key"] as? String, !key.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("key"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let text = params["text"] as? String, !text.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("text"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let secKey = stringKeyToSecKey(key) else {
            let error = NZError.bridgeFailed(reason: .custom("sec key create fail"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if action == "encrypt" {
            var blockSize = SecKeyGetBlockSize(secKey)
            let plainText = Array<UInt8>(text.utf8)
            var cipherText = Array(repeating: UInt8(0), count: blockSize)
            if SecKeyEncrypt(secKey, .PKCS1, plainText, plainText.count, &cipherText, &blockSize) == errSecSuccess {
                bridge.invokeCallbackSuccess(args: args, result: ["text": cipherText.toBase64()])
            } else {
                let error = NZError.bridgeFailed(reason: .custom("encrypt fail"))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        } else {
            var blockSize = SecKeyGetBlockSize(secKey)
            let plainText = Array<UInt8>(text.utf8)
            var cipherText = Array(repeating: UInt8(0), count: blockSize)
            if SecKeyDecrypt(secKey, .PKCS1, plainText, plainText.count, &cipherText, &blockSize) == errSecSuccess {
                bridge.invokeCallbackSuccess(args: args, result: ["text": cipherText])
            } else {
                let error = NZError.bridgeFailed(reason: .custom("decrypt fail"))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        }
    }
    
    private func getRandomValues(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let params = args.paramsString.toDict() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let length = params["length"] as? Int else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("length"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var bytes = [Int8](repeating: 0, count: length)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        if status == errSecSuccess {
            bridge.invokeCallbackSuccess(args: args, result: ["randomValues": bytes])
        } else {
            bridge.invokeCallbackFail(args: args, error: .bridgeFailed(reason: .custom("")))
        }
    }
    
    func stringKeyToSecKey(_ key: String) -> SecKey? {
        guard let certificateData = key.data(using: .utf8) else { return nil }
        let certificate = SecCertificateCreateWithData(nil, certificateData as CFData)
        var trust: SecTrust?
        let policy = SecPolicyCreateBasicX509()
        let status = SecTrustCreateWithCertificates(certificate!, policy, &trust)
        if status == errSecSuccess {
            return SecTrustCopyPublicKey(trust!)
        }
        return nil
    }
    
}
