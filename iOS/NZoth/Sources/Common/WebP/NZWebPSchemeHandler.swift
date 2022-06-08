//
//  NZWebPSchemeHandler.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import WebKit
import SDWebImage
import SDWebImageWebPCoder

class NZWebPSchemeHandler: NSObject, WKURLSchemeHandler {
    
    private var tasks: Set<String> = []
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(NZError.createURLFailed(urlSchemeTask.request.url?.absoluteString ?? ""))
            return
        }
        
        let scheme = "webphttp"
        var urlstr = url.absoluteString
        if urlstr.count > scheme.count {
            if urlstr[urlstr.startIndex..<urlstr.index(urlstr.startIndex, offsetBy: scheme.count)] == scheme {
                urlstr = urlstr.replacingOccurrences(of: scheme, with: "http")
            }
        }
        
        guard let newURL = URL(string: urlstr) else {
            urlSchemeTask.didFailWithError(NZError.createURLFailed(urlstr))
            return
        }
        
        let identifie = urlSchemeTask.description
        tasks.insert(identifie)
        
        SDWebImageManager.shared.loadImage(with: newURL,
                                           options: [.retryFailed],
                                           progress: nil) { image, data, error, _, _, _ in
            if !self.tasks.contains(identifie) {
                return
            }
            self.tasks.remove(identifie)
            if let error = error {
                urlSchemeTask.didFailWithError(error)
            } else if var data = data {
                if NSData.sd_imageFormat(forImageData: data) == .webP,
                   let image = SDImageWebPCoder.shared.decodedImage(with: data, options: [:]),
                   let newData = image.sd_imageData() {
                    data = newData
                }
                self.responseImage(newURL, data: data, urlSchemeTask: urlSchemeTask)
            } else if let image = image, let data = image.sd_imageData() {
                self.responseImage(newURL, data: data, urlSchemeTask: urlSchemeTask)
            } else {
                urlSchemeTask.didFailWithError(NZError.httpRequestFailed)
            }
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        tasks.remove(urlSchemeTask.description)
    }
    
    func responseImage(_ url: URL, data: Data, urlSchemeTask: WKURLSchemeTask) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }
}
