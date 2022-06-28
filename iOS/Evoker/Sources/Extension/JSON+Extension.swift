//
//  JSON+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

extension Data {
    
    func toDict() -> [String: Any]? {
        do {
            let json = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any]
            return json
        } catch {
            Logger.warn("json parse failed: \(error)")
        }
        return nil
    }
    
    func toModel<T: Decodable>() -> T? {
        do {
            let model = try JSONDecoder().decode(T.self, from: self)
            return model
        } catch {
            Logger.warn("json parse failed: \(error)")
        }
        return nil
    }
}

public extension String {
    
    func toDict() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.toDict()
    }
    
    func toModel<T: Decodable>() -> T? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.toModel()
    }
}

extension Dictionary {
    
    func toJSONString() -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: jsonData, encoding: .utf8)
        } catch {
            Logger.warn("json stringify failed: \(error)")
        }
        return nil
    }
    
    func toModel<T: Decodable>() -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: JSONSerialization.data(withJSONObject: self))
        } catch {
            Logger.warn("json parse failed: \(error)")
        }
        return nil
    }
}

extension Encodable {
    
    func toJSONString() -> String? {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(self)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            Logger.warn("json stringify failed: \(error)")
        }
        return nil
    }
}
