//
//  AppStorage.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import SQLite

public class AppStorage {
    
    private var database: Connection?
    
    struct LocalStorageTable {
        let table = Table("LocalStorageData")
        let key = Expression<String>("key")
        let data = Expression<String>("data")
        let dataType = Expression<String>("dataType")
        let length = Expression<Int>("length")
        let updatedAt = Expression<Int>("updatedAt")
        
        init() { }
    }
    
    private let localStorageTable = LocalStorageTable()
    
    struct AuthorizationTable {
        let table = Table("Authorization")
        var scope = Expression<String>("scope")
        let authorized = Expression<Bool>("authorized")
        
        init() { }
    }
    
    private let authorizationTable = AuthorizationTable()
    
    public init(appId: String) {
        let dest = FilePath.storageDatabase(appId: appId)
        do {
            try FilePath.createDirectory(at: dest.deletingLastPathComponent())
            database = try Connection(dest.path)
            createLocalStorageTable()
            createAuthorizationTable()
        } catch {
            Logger.error("sqlite connect \(dest) failed: \(error)")
        }
    }
    
    private func createLocalStorageTable() {
        guard let database = database else { return }
        let createTable = localStorageTable.table.create(ifNotExists: true, block: { t in
            t.column(localStorageTable.key, primaryKey: true)
            t.column(localStorageTable.data)
            t.column(localStorageTable.dataType)
            t.column(localStorageTable.length)
            t.column(localStorageTable.updatedAt)
        })
        do {
            try database.run(createTable)
        } catch {
            Logger.error("sqlite create table LocalStorageData failed: \(error)")
        }
    }
    
    private func createAuthorizationTable() {
        guard let database = database else { return }
        let createTable = authorizationTable.table.create(ifNotExists: true, block: { t in
            t.column(authorizationTable.scope, primaryKey: true)
            t.column(authorizationTable.authorized)
        })
        do {
            try database.run(createTable)
        } catch {
            Logger.error("sqlite create table Authorization failed: \(error)")
        }
    }
}

extension AppStorage {
    
    public func getAllAuthorization() -> ([String: Bool], EKError?) {
        guard let database = database else {
            return ([:], .storageFailed(reason: .connectFailed))
        }
        do {
            let query = authorizationTable.table.select(authorizationTable.scope, authorizationTable.authorized)
            let rows = try database.prepare(query)
            var all: [String: Bool] = [:]
            try rows.forEach { row in
                let scope = try row.get(authorizationTable.scope)
                let authorized = try row.get(authorizationTable.authorized)
                all[scope] = authorized
            }
            return (all, nil)
        } catch {
            return ([:], EKError.storageFailed(reason: .getFailed))
        }
    }
    
    public enum AuthorizationStatus: Int, Encodable {
        case authorized
        case denied
        case notDetermined
    }
    
    public func getAuthorization(_ scope: String) -> (AuthorizationStatus, EKError?) {
        guard let database = database else {
            return (.notDetermined, .storageFailed(reason: .connectFailed))
        }
        do {
            let query = authorizationTable.table.select(authorizationTable.authorized)
                .filter(authorizationTable.scope == scope)
            if let row = try database.pluck(query) {
                let authorized = try row.get(authorizationTable.authorized)
                return (authorized ? .authorized : .denied, nil)
            }
            return (.notDetermined, nil)
        } catch {
            return (.notDetermined, EKError.storageFailed(reason: .getFailed))
        }
    }
    
    public func setAuthorization(_ scope: String, authorized: Bool) -> EKError? {
        guard let database = database else {
            return .storageFailed(reason: .connectFailed)
        }
        do {
            let insert = authorizationTable.table.insert(or: OnConflict.replace,
                                                         authorizationTable.scope <- scope,
                                                         authorizationTable.authorized <- authorized)
            try database.run(insert)
            return nil
        } catch {
            return EKError.storageFailed(reason: .setFailed)
        }
    }
    
    public func clearAuthorization() -> EKError? {
        guard let database = database else {
            return EKError.storageFailed(reason: .connectFailed)
        }
        do {
            let delete = authorizationTable.table.delete()
            try database.run(delete)
            return nil
        } catch {
            return EKError.storageFailed(reason: .clearFailed)
        }
    }
}

extension AppStorage {
    
    public func info() -> (([String], Int, Int)?, EKError?) {
        guard let database = database else {
            return (nil, .storageFailed(reason: .connectFailed))
        }
        do {
            let query = localStorageTable.table.select(localStorageTable.key)
            let rows = try database.prepare(query)
            let keys = try rows.map { try $0.get(localStorageTable.key) }
            let size = try database.scalar(localStorageTable.table.select(localStorageTable.length.sum)) ?? 0
            return ((keys, (size / 1024), 10240), nil)
        } catch {
            return (nil, .storageFailed(reason: .getInfoFailed))
        }
    }
    
    public func get(key: String) -> ((String, String)?, EKError?) {
        guard let database = database else {
            return (nil, EKError.storageFailed(reason: .connectFailed))
        }
        do {
            let query = localStorageTable.table.select(localStorageTable.data, localStorageTable.dataType)
                .filter(localStorageTable.key == key)
            if let row = try database.pluck(query) {
                let data = try row.get(localStorageTable.data)
                let dataType = try row.get(localStorageTable.dataType)
                return ((data, dataType), nil)
            }
            return (nil, EKError.storageFailed(reason: .keyNotExist(key)))
        } catch {
            return (nil, EKError.storageFailed(reason: .getFailed))
        }
    }
    
    public func set(key: String, data: String, dataType: String) -> EKError? {
        guard let database = database else {
            return EKError.storageFailed(reason: .connectFailed)
        }
        do {
            let length = key.lengthOfBytes(using: .utf8) + data.lengthOfBytes(using: .utf8)
            if length > 1024 * 1024 {
                return EKError.storageFailed(reason: .singleKeySizeLimit)
            }
            let size = try database.scalar(localStorageTable.table.select(localStorageTable.length.sum)) ?? 0
            if size + length > 1024 * 1024 * 10 {
                return EKError.storageFailed(reason: .sizeLimited)
            }
            let insert = localStorageTable.table.insert(or: OnConflict.replace,
                                                        localStorageTable.key <- key,
                                                        localStorageTable.data <- data,
                                                        localStorageTable.dataType <- dataType,
                                                        localStorageTable.length <- length,
                                                        localStorageTable.updatedAt <- Int(Date().timeIntervalSince1970))
            try database.run(insert)
            return nil
        } catch {
            return EKError.storageFailed(reason: .setFailed)
        }
    }
    
    public func remove(key: String) -> EKError? {
        guard let database = database else {
            return EKError.storageFailed(reason: .connectFailed)
        }
        do {
            let delete = localStorageTable.table.filter(localStorageTable.key == key).delete()
            try database.run(delete)
            return nil
        } catch {
            return EKError.storageFailed(reason: .removeFailed)
        }
    }
    
    public func clear() -> EKError? {
        guard let database = database else {
            return EKError.storageFailed(reason: .connectFailed)
        }
        do {
            let delete = localStorageTable.table.delete()
            try database.run(delete)
            return nil
        } catch {
            return EKError.storageFailed(reason: .clearFailed)
        }
    }
}
