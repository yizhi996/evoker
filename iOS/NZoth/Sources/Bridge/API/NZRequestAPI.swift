//
//  NZRequestAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Alamofire
import QuartzCore

enum NZRequestAPI: String, NZBuiltInAPI {
   
    case request
    case cancelRequest
    case downloadFile
    case uploadFile
   
    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        switch self {
        case .request:
            request(args: args, bridge: bridge)
        case .cancelRequest:
            cancelRequest(args: args, bridge: bridge)
        case .downloadFile:
            downloadFile(args: args, bridge: bridge)
        case .uploadFile:
            uploadFile(args: args, bridge: bridge)
        }
    }
    
    private func request(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            var task: Int?
            let url: String
            let method: String
            let header: [String: String]
            let timeout: Int
            var data: [String: Any]?
            
            enum CodingKeys: String, CodingKey {
                case task, url, method, header, data, timeout
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                if container.contains(.task) {
                    task = try container.decode(Int.self, forKey: .task)
                }
                url = try container.decode(String.self, forKey: .url)
                method = try container.decode(String.self, forKey: .method)
                header = try container.decode([String: String].self, forKey: .header)
                timeout = try container.decode(Int.self, forKey: .timeout)
                if container.contains(.data) {
                    data = try container.decode([String: Any].self, forKey: .data)
                }
            }
        }
        
        guard let appService = bridge.appService else { return }
        
        let start = CACurrentMediaTime()
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.url.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("url"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        do {
            var urlRequest = try URLRequest(url: params.url,
                                            method: HTTPMethod(rawValue: params.method),
                                            headers: HTTPHeaders(params.header))
            if let data = params.data {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                urlRequest.httpBody = jsonData
            }
            let request = AF.request(urlRequest)
            if let requestId = params.task {
                appService.requests[requestId] = request
            }
            
            request.responseString { [weak bridge] response in
                guard let bridge = bridge else { return }
                
                if let requestId = params.task {
                    bridge.appService?.requests.removeValue(forKey: requestId)
                }
                
                let end = String(format: "%.3f", CACurrentMediaTime() - start)
                NZLogger.debug("HTTP request use time \(end)s")
                
                switch response.result {
                case .success:
                    let callback: [String : Any?] = [
                        "statusCode": response.response?.statusCode,
                        "header": response.response?.headers.dictionary,
                        "data": response.value,
                        "error": "",
                    ]
                    bridge.invokeCallbackSuccess(args: args, result: callback)
                case let .failure(error):
                    let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
                    bridge.invokeCallbackFail(args: args, error: error)
                }
            }
        } catch {
            let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func cancelRequest(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        guard let appService = bridge.appService else { return }
        
        guard let params = args.paramsString.toDict(),
              let requestId = params["id"] as? Int else {
                  let error = NZError.bridgeFailed(reason: .fieldRequired("id"))
                  bridge.invokeCallbackFail(args: args, error: error)
                  return
              }
        
        if let request = appService.requests[requestId] {
            request.cancel()
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func downloadFile(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let task: Int?
            let url: String
            let header: [String: String]
            let filePath: String?
            let timeout: Int
        }
        
        guard let appService = bridge.appService else { return }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.url.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("url"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        var destinationNZFilePath = ""
        let destination: DownloadRequest.Destination = { temporaryURL, response in
            let fn = response.suggestedFilename!
            var ext = "unknown"
            if let extIdx = fn.lastIndex(of: "."), extIdx < fn.endIndex {
                ext = String(fn[fn.index(after: extIdx)..<fn.endIndex])
            }
            let dest = FilePath.createTempNZFilePath(ext: ext)
            destinationNZFilePath = dest.1
            return (dest.0, [.removePreviousFile])
        }
        let request = AF.download(params.url, headers: HTTPHeaders(params.header), to: destination)
        if let requestId = params.task {
            appService.requests[requestId] = request
        }
        request.response { response in
            switch response.result {
            case .success:
                let callback: [String : Any?] = [
                    "statusCode": response.response?.statusCode,
                    "tempFilePath": destinationNZFilePath,
                    "header": response.response?.headers.dictionary,
                    "cookies": [String]()
                ]
                bridge.invokeCallbackSuccess(args: args, result: callback)
            case .failure(let error):
                bridge.invokeCallbackFail(args: args, error: .custom(error.localizedDescription))
            }
        }
    }
    
    private func uploadFile(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct Params: Decodable {
            let task: Int?
            let url: String
            let filePath: String
            let name: String
            let formData: [String: String]
            let header: [String: String]
            let timeout: Int
        }
        
        guard let appService = bridge.appService else { return }
        
        let start = CACurrentMediaTime()
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard !params.url.isEmpty else {
            let error = NZError.bridgeFailed(reason: .fieldRequired("url"))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let filePath = FilePath.nzFilePathToRealFilePath(filePath: params.filePath) else {
            let error = NZError.bridgeFailed(reason: .filePathNotExist(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            let request = AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(data, withName: params.name)
                params.formData.forEach { (key, value) in
                    let data = Data(value.utf8)
                    multipartFormData.append(data, withName: key)
                }
            }, to: params.url, headers: HTTPHeaders(params.header))
            if let requestId = params.task {
                appService.requests[requestId] = request
            }
            request.responseString { [weak bridge] response in
                guard let bridge = bridge else { return }
                
                if let requestId = params.task {
                    bridge.appService?.requests.removeValue(forKey: requestId)
                }
                let end = String(format: "%.3f", CACurrentMediaTime() - start)
                NZLogger.debug("HTTP request use time \(end)s")
                
                switch response.result {
                case .success:
                    let callback: [String : Any?] = [
                        "success": true,
                        "status": response.response?.statusCode,
                        "headers": response.response?.headers.dictionary,
                        "data": response.value,
                        "error": "",
                    ]
                    bridge.invokeCallbackSuccess(args: args, result: callback)
                case let .failure(error):
                    let callback: [String : Any?] = [
                        "success": false,
                        "status": response.response?.statusCode,
                        "headers": response.response?.headers.dictionary,
                        "data": response.value,
                        "error": error.localizedDescription,
                    ]
                    bridge.invokeCallbackSuccess(args: args, result: callback)
                }
            }
        } catch {
            let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
}

