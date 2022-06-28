//
//  BrowserPage.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class BrowserPage: Page {
    
    public let pageId: Int
    
    public let url: String
    
    public weak var appService: AppService?
    
    public weak var viewController: PageViewController?
    
    public var style: AppConfig.Style?
    
    public var isTabBarPage = false
    
    public var isShowTabBar = true
    
    public var isVisible: Bool = false
    
    public required init(appService: AppService, url: String) {
        self.appService = appService
        self.url = url
        pageId = appService.genPageId()
    }
    
    open func generateViewController() -> PageViewController {
        return BrowserPageViewController(page: self)
    }
}
