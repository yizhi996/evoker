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
    
    func rmdir(_ dirPath: String, _ recursive: Bool) -> [String: Any]
    
    func readdir(_ dirPath: String) -> [String: Any]
    
    func readFile(_ options: [String: Any]) -> [String: Any]
    
    func writeFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String: Any]
    
    func rename(_ oldPath: String, _ newPath: String) -> [String: Any]
    
    func copyFile(_ srcPath: String, _ destPath: String) -> [String: Any]
    
    func appendFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String: Any]
    
    func unlink(_ filePath: String) -> [String: Any]
    
    func stat(_ path: String, _ recursive: Bool) -> [String: Any]
    
    func saveFile(_ tempFilePath: String, _ filePath: String) -> [String: Any]
    
    func open(_ filePath: String, _ flag: String) -> [String: Any]
    
    func close(_ fd: String) -> [String: Any]
    
    func fstat(_ fd: String) -> [String: Any]
    
    func ftruncate(_ fd: String, _ length: Int64) -> [String: Any]
    
    func read(_ fd: String, _ arrayBuffer: JSValue, _ offset: Int, _ length: Int, _ position: Int64) -> [String: Any]
    
    func write(_ fd: String, _ data: JSValue, _ offset: Int, _ length: Int, _ position: Int64, _ encoding: String) -> [String: Any]
    
}

@objc class FileSystemManagerObject: NSObject, FileSystemManagerObjectExport {
    
    let ERR_MSG = "errMsg"
    
    var appId = "" {
        didSet {
            try? FilePath.createDirectory(at: FilePath.usr(appId: appId))
            try? FilePath.createDirectory(at: FilePath.store(appId: appId))
        }
    }
    
    lazy var fdMap: [String: Int32] = [:]
    
    override required init() {
        super.init()
    }
    
    func access(_ path: String) -> [String: Any] {
        guard let filePath = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: path) else {
            return [ERR_MSG: "invalid path"]
        }
        
        guard FileManager.default.fileExists(atPath: filePath.path) else {
            return [ERR_MSG: "no such file or directory, access \(path)"]
        }
        
        return [ERR_MSG: ""]
    }
    
    func mkdir(_ dirPath: String, _ recursive: Bool) -> [String: Any] {
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
    
    func rmdir(_ dirPath: String, _ recursive: Bool) -> [String: Any] {
        guard let dirURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: dirPath) else {
            return [ERR_MSG: "invalid dirPath"]
        }
        
        guard FileManager.default.fileExists(atPath: dirURL.path) else {
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
    
    func readdir(_ dirPath: String) -> [String: Any] {
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
        case none
        
        func toFoundation() -> String.Encoding? {
            switch self {
            case .ascii:
                return .ascii
            case .utf8, .binary:
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
    
    func readFile(_ options: [String: Any]) -> [String: Any] {
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
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return [ERR_MSG: "no such file or directory \(params.filePath)"]
        }
        
        do {
            var data = try Data(contentsOf: fileURL)
            let position = params.position ?? 0
            let length = params.length ?? data.count
            data = data[position..<length]
            
            var result: Any?
            if let encoding = params.encoding, encoding != .none {
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
    
    func writeFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String: Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        guard let encoding = Encoding(rawValue: encoding) else {
            return [ERR_MSG: "invalid encoding"]
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
    
    func rename(_ oldPath: String, _ newPath: String) -> [String: Any] {
        guard let oldURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: oldPath) else {
            return [ERR_MSG: "invalid oldPath"]
        }
        
        guard let newURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: newPath) else {
            return [ERR_MSG: "invalid newPath"]
        }
        
        guard FileManager.default.fileExists(atPath: oldURL.path) else {
            return [ERR_MSG: "no such file or directory \(oldPath)"]
        }
        
        do {
            try FileManager.default.moveItem(at: oldURL, to: newURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func copyFile(_ srcPath: String, _ destPath: String) -> [String: Any] {
        guard let srcURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: srcPath) else {
            return [ERR_MSG: "invalid srcPath"]
        }
        
        guard let destURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: destPath) else {
            return [ERR_MSG: "invalid destPath"]
        }
        
        guard FileManager.default.fileExists(atPath: srcURL.path) else {
            return [ERR_MSG: "no such file or directory \(srcPath)"]
        }
        
        do {
            try FileManager.default.copyItem(at: srcURL, to: destURL)
            return [ERR_MSG: ""]
        } catch {
            return [ERR_MSG: error.localizedDescription]
        }
    }
    
    func appendFile(_ filePath: String, _ data: JSValue, _ encoding: String) -> [String: Any] {
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
    
    func unlink(_ filePath: String) -> [String: Any] {
        guard let fileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
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
    
    func stat(_ path: String, _ recursive: Bool) -> [String: Any] {
        guard let url = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: path) else {
            return [ERR_MSG: "invalid filePath"]
        }
        
        func lstat(path: String) -> [String: Any]? {
            let sb: UnsafeMutablePointer<stat> = UnsafeMutablePointer<stat>.allocate(capacity: 1)
            let err = Darwin.lstat(path, sb)
            if err != noErr {
                return nil
            }
            return ["mode": sb.pointee.st_mode,
                    "size": sb.pointee.st_size,
                    "lastAccessedTime": sb.pointee.st_atimespec.tv_sec,
                    "lastModifiedTime": sb.pointee.st_mtimespec.tv_sec]
        }
        
        guard let rootStats = lstat(path: url.path) else { return [ERR_MSG: String(cString: strerror(errno))] }
            
        if recursive {
            if Darwin.opendir(url.path) == nil {
                return [ERR_MSG: "", "stats": rootStats]
            }
            
            var stats: [[String: Any]] = []
            stats.append(["path": "/", "stats": rootStats])
            
            func listdir(path: String) {
                guard let dir = Darwin.opendir(path) else { return }
                while let entry = Darwin.readdir(dir) {
                    let entryName = withUnsafeBytes(of: entry.pointee.d_name) { rawPtr -> String in
                        let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
                        return String(cString: ptr)
                    }
                    
                    guard entryName != "." && entryName != ".." else { continue }
                    
                    let path = "\(path)/\(entryName)"
                    if let stat = lstat(path: path) {
                        stats.append(["path": path.replacingOccurrences(of: url.path, with: ""), "stats": stat])
                    }
                    
                    if entry.pointee.d_type == DT_DIR {
                        listdir(path: path)
                    }
                }
                Darwin.closedir(dir)
            }
            
            listdir(path: url.path)
            return [ERR_MSG: "", "stats": stats]
        }
        return [ERR_MSG: "", "stats": rootStats]
    }
    
    func saveFile(_ tempFilePath: String, _ filePath: String) -> [String : Any] {
        guard let tempFileURL = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: tempFilePath) else {
            return [ERR_MSG: "invalid tempFilePath"]
        }
        
        guard FileManager.default.fileExists(atPath: tempFileURL.path) else {
            return [ERR_MSG: "no such file or directory \(tempFileURL)"]
        }
        
        var destURL: URL
        var savedFilePath: String
        if !filePath.isEmpty {
            if let dest = FilePath.ekFilePathToRealFilePath(appId: appId, filePath: filePath) {
                destURL = dest
                savedFilePath = filePath
            } else {
                return [ERR_MSG: "invalid filePath"]
            }
        } else {
            let fileName = tempFileURL.lastPathComponent
            let (newEKFile, dest) = FilePath.generateStoreEKFilePath(appId: appId, filename: fileName)
            destURL = dest
            savedFilePath = newEKFile
        }
        
        do {
            if FileManager.default.fileExists(atPath: destURL.path) {
                try FileManager.default.removeItem(at: destURL)
            }
            try FileManager.default.moveItem(at: tempFileURL, to: destURL)
            return [ERR_MSG: "", "savedFilePath": savedFilePath]
        } catch {
            return [ERR_MSG: "\(error.localizedDescription)"]
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
    
    func ftruncate(_ fd: String, _ length: Int64) -> [String: Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        let err = Darwin.ftruncate(fileNumber, length)
        if err != noErr {
            return [ERR_MSG: String(cString: strerror(err))]
        }
        
        return [ERR_MSG: ""]
    }
    
    func read(_ fd: String, _ arrayBuffer: JSValue, _ offset: Int, _ length: Int, _ position: Int64) -> [String: Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        var bytes = arrayBuffer.toArrayBuffer()!
        
        if offset > 0 {
            bytes = bytes.advanced(by: offset)
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
    
    func write(_ fd: String,
               _ data: JSValue,
               _ offset: Int,
               _ length: Int,
               _ position: Int64,
               _ encoding: String) -> [String: Any] {
        guard let fileNumber = fdMap[fd] else { return [ERR_MSG: "invalid fd: \(fd)"] }
        
        guard let encoding = Encoding.init(rawValue: encoding) else { return [ERR_MSG: "invalid encoding"] }
        
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
            let len = data.getArrayBufferLength()
            writeData = Data(bytes: bytes, count: len)
            
            let start = offset > 0 ? offset : 0
            if start > len {
                return [ERR_MSG: "offset is out of bounds, requires <= \(len)"]
            }
            
            let end = start + (length > 0 ? length : len)
            if end > len {
                return [ERR_MSG: "offset + length is out of bounds, requires <= \(len)"]
            }
            
            writeData = writeData![start..<end]
        }
        
        if writeData == nil {
            return [ERR_MSG: "invalid data"]
        }
        
        let bytes = writeData!.bytes
        
        if position > 0 {
            let bytesWritten = Darwin.pwrite(fileNumber, bytes, bytes.count, position)
            if bytesWritten == -1 && errno != noErr {
                return [ERR_MSG: String(cString: strerror(errno))]
            }
            return [ERR_MSG: "", "bytesWritten": bytesWritten]
        } else {
            let bytesWritten = Darwin.write(fileNumber, bytes, bytes.count)
            if bytesWritten == -1 && errno != noErr {
                return [ERR_MSG: String(cString: strerror(errno))]
            }
            return [ERR_MSG: "", "bytesWritten": bytesWritten]
        }
    }
}
