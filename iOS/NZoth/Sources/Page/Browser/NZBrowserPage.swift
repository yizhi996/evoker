//
//  NZBrowserPage.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZBrowserPage: NZPage {
    
    public let pageId: Int
    
    public weak var appService: NZAppService?
    
    public weak var viewController: NZPageViewController?
    
    public var style: NZPageStyle?
    
    public var isTabBarPage = false
    
    public var isShowTabBar = true
    
    public var isVisible: Bool = false
    
    public private(set) var url: URL?
    
    public private(set) var cookies: [HTTPCookie] = []
    
    public required init(appService: NZAppService) {
        self.appService = appService
        pageId = appService.genPageId()
    }
    
    public required convenience init?(appService: NZAppService, url: String, cookies: String) {
        guard let url = URL(string: url) else { return nil }
        
        self.init(appService: appService)
        self.url = url
        
        if !cookies.isEmpty {
            self.cookies.append(contentsOf: cookies.converToHTTPCookie())
        }
    }
    
    open func generateViewController() -> NZPageViewController {
        return NZBrowserViewController(page: self)
    }
}
