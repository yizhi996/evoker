//
//  String+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension String {
    
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from + 1)
        return String(self[start ..< end])
    }
    
    func substring(range: NSRange) -> String {
        return substring(from: range.location, to: range.location + range.length - 1)
    }
}

extension String {
    
    func size(with font: UIFont, width: CGFloat) -> CGSize {
            
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        let attributedString = NSAttributedString(string: self, attributes: [.font : font, .paragraphStyle: style])
        let rect = attributedString.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                 options: [.usesFontLeading, .usesLineFragmentOrigin],
                                                 context: nil)
        return rect.size
    }
    
    func height(with font: UIFont, width: CGFloat) -> CGFloat {
        return size(with: font, width: width).height
    }
}

extension String {
    
    func decodeURL() -> (String, [String: String]) {
        guard let components = URLComponents(string: self) else { return (self, [:]) }
        var query: [String: String] = [:]
        components.queryItems?.forEach { item in
            query[item.name] = item.value
        }
        return (components.path, query)
    }
    
    func query() -> [String: String] {
        let (_, query) = decodeURL()
        return query
    }
}

extension String {
    
    func converToHTTPCookie() -> [HTTPCookie] {
        var result: [HTTPCookie] = []
        split(separator: "\n").forEach { cookie in
//            var params = cookie.split(separator: ";")
//            if !params.isEmpty {
//                let first = params[0]
//                let kv = first.split(separator: "=")
//                var property = [HTTPCookiePropertyKey: Any]()
//                property[.name] = kv[0]
//                property[.value] = kv[1]
//                params.remove(at: 0)
//                params.forEach { p in
//                    let params = String(p)
//                    let kv = params.split(separator: "=")
//                    if kv.count == 2 {
//                        let key = kv[0].trimmingCharacters(in: .whitespacesAndNewlines)
//                        let value = kv[1]
//                        if key == "path" {
//                            property[.path] = value
//                        } else if key == "domain" {
//                            property[.domain] = value
//                        } else if key == "expires" {
//                            property[.expires] = value
//                        }
//                    } else {
//                        let key = params.trimmingCharacters(in: .whitespacesAndNewlines)
//                        if key == "secure" {
//                            property[.secure] = true
//                        }
//                    }
//                }
//                if let cookie = HTTPCookie(properties: property) {
//                    result.append(cookie)
//                }
            if let ck = parseCookie(String(cookie)) {
                result.append(ck)
            }
//            }
        }
        return result
    }
    
    func parseCookie(_ string: String) -> HTTPCookie? {
        var name: String
        var values: String
        
        let parts = string.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
        guard parts.count == 2 else { return nil }
        
        name = String(parts[0]).trimmingCharacters(in: .whitespaces)
        values = String(parts[1]).trimmingCharacters(in: .whitespaces)
            
        var expires: String = ""
        var maxAge: Int = 0
        var domain: String = ""
        var path: String = "/"
        var secure = false
        var httpOnly = false
            
        let value = String(values.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false).first!)
        let params = values.components(separatedBy: ";").compactMap { x ->(String, String)? in
            let parts = x.components(separatedBy: "=")
            if parts.count == 2 {
                return (parts[0].trimmingCharacters(in: .whitespaces),
                        parts[1].trimmingCharacters(in: .whitespaces))
            }
            return nil
        }
        
        for (key, val) in params {
            switch key {
            case "domain": domain = val
            case "path": path = val
            case "expires": expires = val
            case "httponly": httpOnly = true
            case "secure": secure = true
            case "max-age": maxAge = Int(val) ?? 0

            default: break
            }
        }
            
        return HTTPCookie(properties: [
            .name: name,
            .value: value,
            .domain: domain,
            .path: path,
            .expires: NSDate.init(timeIntervalSinceNow: 3 * 60 * 60),
            .secure: secure,
        ])
       
    }
}

extension String {
    
    static func random(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
