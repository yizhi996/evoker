//
//  NZAppCenterDatabase.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import SQLite

class NZAppCenterDatabase {
    
    var database: Connection?
    
    init() {
        let dest = FilePath.mainDatabase()
        do {
            try FilePath.createDirectory(at: dest.deletingLastPathComponent())
            database = try Connection(dest.path)
            createAppCenterTable()
        } catch {
            NZLogger.error("sqlite connect \(dest) failed: \(error)")
        }
    }
    
    func createAppCenterTable() {
        guard let database = database else { return }
        let appCenter = Table("NZAppCenterTable")
        
        let appId = Expression<String>("appId")
        let appName = Expression<String>("appName")
        let iconURL = Expression<String>("iconURL")
        let appVersion = Expression<String>("appVersion")
        let trailAppVersion = Expression<String>("trailAppVersion")
        
        let createTable = appCenter.create(ifNotExists: true, block: { t in
            t.column(appId, primaryKey: true)
            t.column(appName)
            t.column(iconURL)
            t.column(appVersion)
            t.column(trailAppVersion)
        })
        do {
            try database.run(createTable)
        } catch {
            NZLogger.error("sqlite create table NZAppCenterTable failed: \(error)")
        }
    }
}

extension NZAppCenterDatabase {
    
    func findApp(appId: String) {
        guard let database = database else { return }
        do {
            let table = Table("NZAppCenterTable")
            let appIdField = Expression<String>("appId")
            let query = table.filter(appIdField == appId)
            if let result = try database.pluck(query) {
                
            }
        } catch {
            
        }
    }
    
    func updateApp(appId: String) {
        
    }
}
