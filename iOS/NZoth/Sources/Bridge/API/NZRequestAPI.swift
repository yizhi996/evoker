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
   
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        switch self {
        case .request:
            request(appService: appService, bridge: bridge, args: args)
        case .cancelRequest:
            cancelRequest(appService: appService, bridge: bridge, args: args)
        case .downloadFile:
            downloadFile(appService: appService, bridge: bridge, args: args)
        case .uploadFile:
            uploadFile(appService: appService, bridge: bridge, args: args)
        }
    }
    
    private func request(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let taskId: String
            let url: String
            let method: String
            let header: [String: String]
            let timeout: TimeInterval
            let responseType: ResponseType
            let data: String
            
            enum ResponseType: String, Decodable {
                case text
                case arraybuffer
            }
        }
        
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
            var header = HTTPHeaders(params.header)
            if !NZEngine.shared.userAgent.isEmpty {
                header.update(.userAgent(NZEngine.shared.userAgent))
            }
            var urlRequest = try URLRequest(url: params.url,
                                            method: HTTPMethod(rawValue: params.method),
                                            headers: header)
            urlRequest.timeoutInterval = params.timeout / 1000
            
            if !params.data.isEmpty {
                urlRequest.httpBody = params.data.data(using: .utf8)
            }
                        
            let request = AF.request(urlRequest)
            
            let taskId = params.taskId
            appService.requests[taskId] = request
            
            request.responseData(completionHandler: { [weak bridge] response in
                guard let bridge = bridge else { return }
                
                bridge.appService?.requests.removeValue(forKey: taskId)
                
                switch response.result {
                case .success(let data):
                    let url = response.request!.url!
                    let header = response.response!.headers.dictionary
                    let cookies = HTTPCookie.cookies(withResponseHeaderFields: header, for: url).map { cookie -> String? in
                        var res = ["\(cookie.name)=\(cookie.value)"]
                        cookie.properties?.forEach {
                            if $0.key != .name && $0.key != .value {
                                res.append("\($0.key.rawValue)=\($0.value)")
                            }
                        }
                        return res.joined(separator: "; ")
                    }
                    
                    var result: Any
                    if params.responseType == .arraybuffer {
                        result = data.bytes
                    } else {
                        result = responseSerializerToString(response)
                    }
                    bridge.invokeCallbackSuccess(args: args, result: ["statusCode": response.response!.statusCode,
                                                                      "header": header,
                                                                      "cookies": cookies,
                                                                      "data": result])
                case .failure(let error):
                    let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
                    bridge.invokeCallbackFail(args: args, error: error)
                }
            })
        } catch {
            let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
            bridge.invokeCallbackFail(args: args, error: error)
        }
    }
    
    private func responseSerializerToString(_ response: AFDataResponse<Data>) -> String {
        let result = try? StringResponseSerializer().serialize(request: response.request,
                                                               response: response.response,
                                                               data: response.data,
                                                               error: response.error)
        return result ?? ""
    }
    
    private func cancelRequest(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let params = args.paramsString.toDict(),
              let taskId = params["taskId"] as? String else {
                  let error = NZError.bridgeFailed(reason: .fieldRequired("taskId"))
                  bridge.invokeCallbackFail(args: args, error: error)
                  return
              }
        
        if let request = appService.requests[taskId] {
            request.cancel()
        }
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func downloadFile(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let taskId: String
            let url: String
            let header: [String: String]
            let filePath: String
            let timeout: TimeInterval
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
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
            
            let dest: URL
            if !params.filePath.isEmpty {
                dest = FilePath.usr(appId: appService.appId, path: params.filePath)
            } else {
                let (nzfile, filePath) = FilePath.generateTmpNZFilePath(ext: ext)
                destinationNZFilePath = nzfile
                dest = filePath
            }
            return (dest, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let request = AF.download(params.url, headers: HTTPHeaders(params.header), to: destination)
        appService.requests[params.taskId] = request
        request.downloadProgress { [weak bridge] progress in
            guard let bridge = bridge else { return }
            let key = NZSubscribeKey("APP_DOWNLOAD_FILE_PROGRESS")
            bridge.subscribeHandler(method: key, data: [
                "taskId": params.taskId,
                "progress": progress.fractionCompleted * 100,
                "totalBytesWritten": progress.totalUnitCount,
                "totalBytesExpectedToWrite": progress.completedUnitCount
            ])
        }
        
        request.responseData { [weak bridge] response in
            guard let bridge = bridge else { return }
            
            bridge.appService?.requests.removeValue(forKey: params.taskId)
            
            switch response.result {
            case .success(let data):
                bridge.invokeCallbackSuccess(args: args, result: [
                    "statusCode": response.response!.statusCode,
                    "tempFilePath": destinationNZFilePath,
                    "header": response.response!.headers.dictionary,
                    "dataLength": data.count
                ])
            case .failure(let error):
                let error = NZError.bridgeFailed(reason: .networkError(error.localizedDescription))
                bridge.invokeCallbackFail(args: args, error: error)
            }
        }
    }
    
    private func uploadFile(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let taskId: String
            let url: String
            let filePath: String
            let name: String
            let formData: [String: String]
            let header: [String: String]
            let timeout: TimeInterval
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let filePath = FilePath.nzFilePathToRealFilePath(appId: appService.appId, filePath: params.filePath) else {
            let error = NZError.bridgeFailed(reason: .filePathNotExist(params.filePath))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        do {
            let data = try Data(contentsOf: filePath)
            let request = AF.upload(multipartFormData: { multipartFormData in
                params.formData.forEach { (key, value) in
                    multipartFormData.append(Data(value.utf8), withName: key)
                }
                multipartFormData.append(data, withName: params.name)
            }, to: params.url, headers: HTTPHeaders(params.header))
            appService.requests[params.taskId] = request
            request.uploadProgress { [weak bridge] progress in
                guard let bridge = bridge else { return }
                let key = NZSubscribeKey("APP_UPLOAD_FILE_PROGRESS")
                bridge.subscribeHandler(method: key, data: [
                    "taskId": params.taskId,
                    "progress": progress.fractionCompleted * 100,
                    "totalBytesWritten": progress.totalUnitCount,
                    "totalBytesExpectedToWrite": progress.completedUnitCount
                ])
            }
            request.response { [weak bridge] response in
                guard let bridge = bridge else { return }
                
                bridge.appService?.requests.removeValue(forKey: params.taskId)
                
                switch response.result {
                case .success(let data):
                    var res = ""
                    if let data = data {
                        res = String(data: data, encoding: .utf8) ?? ""
                    }
                    let callback: [String : Any] = [
                        "statusCode": response.response!.statusCode,
                        "header": response.response!.headers.dictionary,
                        "data": res,
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
}

