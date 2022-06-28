//
//  Module.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public protocol Module {
    
    static var name: String { get }
    
    static var apis: [String: API] { get }
    
    init(appService: AppService)
    
    func onLaunch(_ service: AppService)
    
    func onShow(_ service: AppService)
    
    func onHide(_ service: AppService)
    
    func onExit(_ service: AppService)
    
    func onLoad(_ page: Page)
    
    func onShow(_ page: Page)
    
    func onHide(_ page: Page)
    
    func onUnload(_ page: Page)
    
    func onPageScroll(_ page: Page)
}

public extension Module {
    
    func onLaunch(_ service: AppService) { }
    
    func onShow(_ service: AppService) { }
    
    func onHide(_ service: AppService) { }
    
    func onExit(_ service: AppService) { }
    
    func onLoad(_ page: Page) { }
    
    func onShow(_ page: Page) { }
    
    func onHide(_ page: Page) { }
    
    func onUnload(_ page: Page) { }
    
    func onPageScroll(_ page: Page) { }
}
