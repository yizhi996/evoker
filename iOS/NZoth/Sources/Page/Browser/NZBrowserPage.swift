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
    
    public let url: String
    
    public weak var appService: NZAppService?
    
    public weak var viewController: NZPageViewController?
    
    public var style: NZPageStyle?
    
    public var isTabBarPage = false
    
    public var isShowTabBar = true
    
    public var isVisible: Bool = false
    
    public required init(appService: NZAppService, url: String) {
        self.appService = appService
        self.url = url
        pageId = appService.genPageId()
    }
    
    open func generateViewController() -> NZPageViewController {
        return NZBrowserViewController(page: self)
    }
}
