//
//  NZModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public protocol NZModule {
    
    static var name: String { get }
    
    static var apis: [String: NZAPI] { get }
    
    init(appService: NZAppService)
    
    func willExitPage(_ page: NZPage)
    
    func willExitApp(_ app: NZAppService)
}

public extension NZModule {
    
    func willExitPage(_ page: NZPage) {
        
    }
    
    func willExitApp(_ app: NZAppService) {
        
    }
}
