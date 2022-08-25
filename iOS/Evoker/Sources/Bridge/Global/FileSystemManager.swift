//
//  FileSystemManager.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc public protocol FileSystemManagerObjectExport: JSExport {
    
    init()
    
    func access(_ path: String) -> [String: Any]
    
    func mkdir(_ dirPath: String, _ recursive: Bool) -> [String: Any]
    
    func rmdir(_ dirPath: String, _ recursive: Bool) -> [String : Any]
    
    func readdir(_ dirPath: String) -> [String: Any]
    
    func readFile(_ options: [String: Any]) -> [String: Any]
    
    func writeFile(_ options: [String : Any]) -> [String : Any]
    
    func rename(_ oldPath: String, _ newPath: String) -> [String : Any]
    
    func copy(_ srcPath: String, _ destPath: String) -> [String : Any]
}

@objc public class FileSystemManagerObject: NSObject, FileSystemManagerObjectExport {
    
    let ERR_MSG = "errMsg"
    
    var appId = ""
    
    var envVersion = AppEnvVersion.develop
    
    override public required init() {
        super.init()
        
        try? FilePath.createDirectory(at: FilePath.usr(appId: appId))
    }
    
    public func access(_ path: String) -> [String: Any] {
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: path) {
            if FileManager.default.fileExists(atPath: filePath.path) {
                return [ERR_MSG: ""]
            }
            return [ERR_MSG: "no such file or directory, access \(path)"]
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func mkdir(_ dirPath: String, _ recursive: Bool) -> [String : Any] {
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) {
            do {
                try FileManager.default.createDirectory(at: filePath, withIntermediateDirectories: recursive)
                return [ERR_MSG: ""]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func rmdir(_ dirPath: String, _ recursive: Bool) -> [String : Any] {
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                return [ERR_MSG: "no such file or directory \(dirPath)"]
            }
            do {
                if !recursive {
                    let files = try FileManager.default.contentsOfDirectory(atPath: filePath.path)
                    if !files.isEmpty {
                        return [ERR_MSG: "directory not empty"]
                    }
                }
                try FileManager.default.removeItem(at: filePath)
                return [ERR_MSG: ""]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func readdir(_ dirPath: String) -> [String : Any] {
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                return [ERR_MSG: "no such file or directory \(dirPath)"]
            }
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: filePath.path)
                return [ERR_MSG: "", "files": files]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    enum Encoding: String, Decodable {
        case ascii
        case base64
        case hex
        case utf16le
        case utf8
        case latin1
        case ucs2
        
        func toFoundation() -> String.Encoding? {
            switch self {
            case .ascii:
                return .ascii
            case .utf8:
                return .utf8
            case .utf16le ,.ucs2:
                return .utf16LittleEndian
            case .latin1:
                return .isoLatin1
            default:
                return nil
            }
        }
    }
    
    public func readFile(_ options: [String : Any]) -> [String : Any] {
        struct Params: Decodable {
            let filePath: String
            let encoding: Encoding?
            let position: Int?
            let length: Int?
        }
        
        guard let params: Params = options.toModel() else { return [ERR_MSG: "invalid params"] }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: params.filePath) {
            if !FileManager.default.fileExists(atPath: filePath.path) {
                return [ERR_MSG: "no such file or directory \(params.filePath)"]
            }
            do {
                var data = try Data(contentsOf: filePath)
                let position = params.position ?? 0
                let length = params.length ?? data.count
                data = data[position..<length]
                
                var result: Any?
                if let encoding = params.encoding {
                    if let encoding = encoding.toFoundation() {
                        result = String(data: data, encoding: encoding)
                    } else if encoding == .base64 {
                        result = data.base64EncodedString()
                    } else if encoding == .hex {
                        result = data.map{ String(format:"%02hhx", $0) }.joined()
                    }
                } else {
                    result = data.bytes
                }
                
                if let result = result {
                    return [ERR_MSG: "", "data": result]
                }
                return [ERR_MSG: "encoding fail"]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func writeFile(_ options: [String : Any]) -> [String : Any] {
        struct Params: Decodable {
            let filePath: String
            let data: Any
            let encoding: Encoding
            
            enum CodingKeys: String, CodingKey {
                case filePath, data, encoding
            }
            
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                filePath = try container.decode(String.self, forKey: .filePath)
                encoding = try container.decode(Encoding.self, forKey: .encoding)
                
                if let data = try? container.decode(String.self, forKey: .data) {
                    self.data = data
                } else if let data = try? container.decode([UInt8].self, forKey: .data) {
                    self.data = data
                } else {
                    throw EKError.custom("data must be string or ArrayBuffer")
                }
            }
        }
        
        guard let params: Params = options.toModel() else { return [ERR_MSG: "invalid params"] }
        
        if let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: params.filePath) {
            if !FileManager.default.fileExists(atPath: filePath.deletingLastPathComponent().path) {
                return [ERR_MSG: "no such file or directory \(params.filePath)"]
            }
            
            var data: Data?
            if let string = params.data as? String {
                if let encoding = params.encoding.toFoundation() {
                    data = string.data(using: encoding)
                } else if params.encoding == .base64 {
                    data = Data(base64Encoded: string)
                } else if params.encoding == .hex {
                    data = Data(hex: string)
                }
            } else if let bytesData = params.data as? Array<UInt8> {
                data = Data(bytesData)
            }
            
            if let data = data {
                if FileManager.default.createFile(atPath: filePath.path, contents: data) {
                    return [ERR_MSG: ""]
                } else {
                    return [ERR_MSG: "failed"]
                }
            } else {
                return [ERR_MSG: "encode failed"]
            }
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func rename(_ oldPath: String, _ newPath: String) -> [String : Any] {
        if let oldURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: oldPath),
           let newURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: newPath) {
            if !FileManager.default.fileExists(atPath: oldURL.path) {
                return [ERR_MSG: "no such file or directory \(oldPath)"]
            }
            
            do {
                try FileManager.default.moveItem(at: oldURL, to: newURL)
                return [ERR_MSG: ""]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
            
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
    
    public func copy(_ srcPath: String, _ destPath: String) -> [String : Any] {
        if let srcURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: srcPath),
           let destURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: destPath) {
            if !FileManager.default.fileExists(atPath: srcURL.path) {
                return [ERR_MSG: "no such file or directory \(srcPath)"]
            }
            
            do {
                try FileManager.default.copyItem(at: srcURL, to: destURL)
                return [ERR_MSG: ""]
            } catch {
                return [ERR_MSG: error.localizedDescription]
            }
            
        } else {
            return [ERR_MSG: "invalid path"]
        }
    }
}
