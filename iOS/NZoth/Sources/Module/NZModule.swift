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
    
    func onLaunch(_ service: NZAppService)
    
    func onShow(_ service: NZAppService)
    
    func onHide(_ service: NZAppService)
    
    func onExit(_ service: NZAppService)
    
    func onLoad(_ page: NZPage)
    
    func onShow(_ page: NZPage)
    
    func onHide(_ page: NZPage)
    
    func onUnload(_ page: NZPage)
    
    func onPageScroll(_ page: NZPage)
}

public extension NZModule {
    
    func onLaunch(_ service: NZAppService) { }
    
    func onShow(_ service: NZAppService) { }
    
    func onHide(_ service: NZAppService) { }
    
    func onExit(_ service: NZAppService) { }
    
    func onLoad(_ page: NZPage) { }
    
    func onShow(_ page: NZPage) { }
    
    func onHide(_ page: NZPage) { }
    
    func onUnload(_ page: NZPage) { }
    
    func onPageScroll(_ page: NZPage) { }
}
