//
//  NZAppStorage.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import SQLite

public class NZAppStorage {
    
    private var database: Connection?
    
    private let table = Table("LocalStorageData")
    private let key = Expression<String>("key")
    private let data = Expression<String>("data")
    private let dataType = Expression<String>("dataType")
    private let length = Expression<Int>("length")
    private let updatedAt = Expression<Int>("updatedAt")
    
    public init(appId: String) {
        let dest = FilePath.storageDatabase(appId: appId, userId: NZEngine.shared.userId)
        do {
            try FilePath.createDirectory(at: dest.deletingLastPathComponent())
            database = try Connection(dest.path)
            createTable()
        } catch {
            NZLogger.error("sqlite connect \(dest) failed: \(error)")
        }
    }
    
    private func createTable() {
        guard let database = database else { return }
        let createTable = table.create(ifNotExists: true, block: { t in
            t.column(key, primaryKey: true)
            t.column(data)
            t.column(dataType)
            t.column(length)
            t.column(updatedAt)
        })
        do {
            try database.run(createTable)
        } catch {
            NZLogger.error("sqlite create table LocalStorageData failed: \(error)")
        }
    }
}

extension NZAppStorage {
    
    public func info() -> (([String], Int, Int)?, NZError?) {
        guard let database = database else {
            return (nil, .storageFailed(reason: .connectFailed))
        }
        do {
            let query = table.select(self.key)
            let rows = try database.prepare(query)
            let keys = try rows.map { try $0.get(self.key) }
            let size = try database.scalar(table.select(self.length.sum)) ?? 0
            return ((keys, (size / 1024), 10240), nil)
        } catch {
            return (nil, .storageFailed(reason: .getInfoFailed))
        }
    }
    
    public func get(key: String) -> ((String, String)?, NZError?) {
        guard let database = database else {
            return (nil, NZError.storageFailed(reason: .connectFailed))
        }
        do {
            let query = table.select(data, dataType).filter(self.key == key)
            if let row = try database.pluck(query) {
                let data = try row.get(data)
                let dataType = try row.get(dataType)
                return ((data, dataType), nil)
            }
            return (nil, NZError.storageFailed(reason: .keyNotExist(key)))
        } catch {
            return (nil, NZError.storageFailed(reason: .getFailed))
        }
    }
    
    public func set(key: String, data: String, dataType: String) -> NZError? {
        guard let database = database else {
            return NZError.storageFailed(reason: .connectFailed)
        }
        do {
            let length = key.lengthOfBytes(using: .utf8) + data.lengthOfBytes(using: .utf8)
            let size = try database.scalar(table.select(self.length.sum)) ?? 0
            if size + length > 1024 * 1024 * 10 {
                return NZError.storageFailed(reason: .sizeLimited)
            }
            let insert = table.insert(or: OnConflict.replace,
                                      self.key <- key,
                                      self.data <- data,
                                      self.dataType <- dataType,
                                      self.length <- length,
                                      self.updatedAt <- Int(Date().timeIntervalSince1970))
            try database.run(insert)
            return nil
        } catch {
            return NZError.storageFailed(reason: .setFailed)
        }
    }
    
    public func remove(key: String) -> NZError? {
        guard let database = database else {
            return NZError.storageFailed(reason: .connectFailed)
        }
        do {
            let delete = table.filter(self.key == key).delete()
            try database.run(delete)
            return nil
        } catch {
            return NZError.storageFailed(reason: .removeFailed)
        }
    }
    
    public func clear() -> NZError? {
        guard let database = database else {
            return NZError.storageFailed(reason: .connectFailed)
        }
        do {
            let delete = table.delete()
            try database.run(delete)
            return nil
        } catch {
            return NZError.storageFailed(reason: .clearFailed)
        }
    }
}
