//
//  FileSystemManager.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import JavaScriptCore

@objc protocol FileSystemManagerObjectExport: JSExport {
    
    init()
    
    func access(_ path: String) -> [String: Any]
    
    func mkdir(_ dirPath: String, _ recursive: Bool) -> [String: Any]
    
    func rmdir(_ dirPath: String, _ recursive: Bool) -> [String : Any]
    
    func readdir(_ dirPath: String) -> [String: Any]
    
    func readFile(_ options: [String: Any]) -> [String: Any]
    
    func writeFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String : Any]
    
    func rename(_ oldPath: String, _ newPath: String) -> [String : Any]
    
    func copy(_ srcPath: String, _ destPath: String) -> [String : Any]
    
    func appendFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String : Any]
    
    func unlink(_ filePath: String) -> [String : Any]
    
    func open(_ filePath: String, _ flag: String) -> [String: Any]
    
    func close(_ fd: String) -> [String: Any]
    
    func fstat(_ fd: String) -> [String: Any]
    
    func ftruncate(_ fd: String, _ length: Int64) -> [String: Any]
    
    func read(_ fd: String, _ arrayBuffer: JSValue, _ offset: Int64, _ length: Int, _ position: Int64) -> [String : Any]
}

@objc class FileSystemManagerObject: NSObject, FileSystemManagerObjectExport {
    
    let ERR_MSG = "errMsg"
    
    var appId = ""
    
    lazy var fdMap: [String: Int32] = [:]
    
    override required init() {
        super.init()
        
        try? FilePath.createDirectory(at: FilePath.usr(appId: appId))
    }
    
    func access(_ path: String) -> [String: Any] {
        guard let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: path) else {
            return [ERR_MSG: "invalid path"]
        }
        
        if FileManager.default.fileExists(atPath: filePath.path) {
            return [ERR_MSG: ""]
        }
        return [ERR_MSG: "no such file or directory, access \(path)"]
    }
    
    func mkdir(_ dirPath: String, _ recursive: Bool) -> [String : Any] {
        guard let dirURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) else {
            return [ERR_MSG: "invalid dirPath"]
        }
        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: recursive)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func rmdir(_ dirPath: String, _ recursive: Bool) -> [String : Any] {
        guard let dirURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) else {
            return [ERR_MSG: "invalid dirPath"]
        }
        
        if !FileManager.default.fileExists(atPath: dirURL.path) {
            return [ERR_MSG: "no such file or directory \(dirPath)"]
        }
        do {
            if !recursive {
                let files = try FileManager.default.contentsOfDirectory(atPath: dirURL.path)
                if !files.isEmpty {
                    return [ERR_MSG: "directory not empty"]
                }
            }
            try FileManager.default.removeItem(at: dirURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func readdir(_ dirPath: String) -> [String : Any] {
        guard let dirURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) else {
            return [ERR_MSG: "invalid dirPath"]
        }
        
        if !FileManager.default.fileExists(atPath: dirURL.path) {
            return [ERR_MSG: "no such file or directory \(dirPath)"]
        }
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: dirURL.path)
            return [ERR_MSG: "", "files": files]
        } catch {
            return [ERR_MSG: error.localizedDescription]
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
        case binary
        
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
    
    func readFile(_ options: [String : Any]) -> [String : Any] {
        struct Params: Decodable {
            let filePath: String
            let encoding: Encoding?
            let position: Int?
            let length: Int?
        }
        
        guard let params: Params = options.toModel() else { return [ERR_MSG: "invalid params"] }
        
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: params.filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return [ERR_MSG: "no such file or directory \(params.filePath)"]
        }
        do {
            var data = try Data(contentsOf: fileURL)
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
    }
    
    func writeFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String : Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        guard let encoding = Encoding(rawValue: encoding) else {
            return [ERR_MSG: "invalid encoding"]
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return [ERR_MSG: "no such file or directory \(filePath)"]
        }
        
        var writeData: Data?
        if data.isString {
            let string = data.toString()!
            if let encoding = encoding.toFoundation() {
                writeData = string.data(using: encoding)
            } else if encoding == .base64 {
                writeData = Data(base64Encoded: string)
            } else if encoding == .hex {
                writeData = Data(hex: string)
            }
        } else if let bytes = data.toArrayBuffer() {
            writeData = Data(bytes: bytes, count: data.getArrayBufferLength())
        }
        
        if let writeData = writeData {
            if FileManager.default.createFile(atPath: fileURL.path, contents: writeData) {
                return [ERR_MSG: ""]
            } else {
                return [ERR_MSG: "failed"]
            }
        } else {
            return [ERR_MSG: "encode failed"]
        }
    }
    
    func rename(_ oldPath: String, _ newPath: String) -> [String : Any] {
        guard let oldURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: oldPath) else {
            return [ERR_MSG: "invalid oldPath"]
        }
        
        guard let newURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: newPath) else {
            return [ERR_MSG: "invalid newPath"]
        }
        
        if !FileManager.default.fileExists(atPath: oldURL.path) {
            return [ERR_MSG: "no such file or directory \(oldPath)"]
        }
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func copy(_ srcPath: String, _ destPath: String) -> [String : Any] {
        guard let srcURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: srcPath) else {
            return [ERR_MSG: "invalid srcPath"]
        }
        
        guard let destURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: destPath) else {
            return [ERR_MSG: "invalid destPath"]
        }
        
        if !FileManager.default.fileExists(atPath: srcURL.path) {
            return [ERR_MSG: "no such file or directory \(srcPath)"]
        }
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func appendFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String : Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        guard let encoding = Encoding(rawValue: encoding) else {
            return [ERR_MSG: "invalid encoding"]
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return [ERR_MSG: "no such file or directory \(filePath)"]
        }
        
        var appendData: Data?
        if data.isString {
            let string = data.toString()!
            if let encoding = encoding.toFoundation() {
                appendData = string.data(using: encoding)
            } else if encoding == .base64 {
                appendData = Data(base64Encoded: string)
            } else if encoding == .hex {
                appendData = Data(hex: string)
            }
        } else if let bytes = data.toArrayBuffer() {
            appendData = Data(bytes: bytes, count: data.getArrayBufferLength())
        }
        
        if let appendData = appendData {
            do {
                let handler = try FileHandle(forWritingTo: fileURL)
                handler.seekToEndOfFile()
                handler.write(appendData)
                handler.closeFile()
                return [ERR_MSG: ""]
            } catch {
                return [ERR_MSG: "\(error.localizedDescription)"]
            }
        } else {
            return [ERR_MSG: "encode failed"]
        }
    }
    
    func unlink(_ filePath: String) -> [String : Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            return [ERR_MSG: "no such file or directory \(filePath)"]
        }
        
        do {
            if let isDirectory = try fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory, isDirectory {
                return [ERR_MSG: "\(filePath) is a directory"]
            }
            try FileManager.default.removeItem(at: fileURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func generateFD() -> String {
        let id = String.random(length: 5)
        if fdMap.keys.contains(id) {
            return generateFD()
        }
        return id
    }
    
    func open(_ filePath: String, _ flag: String) -> [String: Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return  [ERR_MSG: "invalid fileURL"]
        }
        
        guard let file = Darwin.fopen(fileURL.path, flag) else { return [ERR_MSG: String(cString: strerror(errno))] }
        
        let fd = generateFD()
        fdMap[fd] = fileno(file)
        return [ERR_MSG: "", "fd": fd]
    }
    
    func close(_ fd: String) -> [String: Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        let err = Darwin.close(fileNumber)
        if err != noErr {
            return [ERR_MSG: String(cString: strerror(err))]
        }
        fdMap[fd] = nil
        return [ERR_MSG: ""]
    }
    
    func closeAll() {
        fdMap.values.forEach { Darwin.close($0) }
        fdMap = [:]
    }
    
    func fstat(_ fd: String) -> [String: Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        let sb: UnsafeMutablePointer<stat> = UnsafeMutablePointer<stat>.allocate(capacity: 1)
        let err = Darwin.fstat(fileNumber, sb)
        if err != noErr {
            return [ERR_MSG: String(cString: strerror(err))]
        }
        
        return [ERR_MSG: "", "stats": ["mode": sb.pointee.st_mode,
                                      "size": sb.pointee.st_size,
                                       "lastAccessedTime": sb.pointee.st_atimespec.tv_sec,
                                       "lastModifiedTime": sb.pointee.st_mtimespec.tv_sec]]
    }
    
    func ftruncate(_ fd: String, _ length: Int64) -> [String : Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        let err = Darwin.ftruncate(fileNumber, length)
        if err != noErr {
            return [ERR_MSG: String(cString: strerror(err))]
        }
        
        return [ERR_MSG: ""]
    }
    
    func read(_ fd: String, _ arrayBuffer: JSValue, _ offset: Int64, _ length: Int, _ position: Int64) -> [String : Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        var bytes = arrayBuffer.toArrayBuffer()!
        
        if offset > 0 {
            bytes = bytes.advanced(by: Int(offset))
        }
        
        if position > 0 {
            let bytesRead = Darwin.pread(fileNumber, bytes, length, position)
            if bytesRead == -1 && errno != noErr {
                return [ERR_MSG: String(cString: strerror(errno))]
            }
            return [ERR_MSG: "", "bytesRead": bytesRead]
        } else {
            let bytesRead = Darwin.read(fileNumber, bytes, length)
            if bytesRead == -1 && errno != noErr {
                return [ERR_MSG: String(cString: strerror(errno))]
            }
            return [ERR_MSG: "", "bytesRead": bytesRead]
        }
    }
}
