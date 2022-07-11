//
//  Page.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol Page: AnyObject {
    
    var pageId: Int { get }
    
    var url: String { get }
    
    var appService: AppService? { get set }
    
    var viewController: PageViewController? { get set }
    
    var style: AppConfig.Style? { get set }
    
    var isTabBarPage: Bool { get set }
    
    var isShowTabBar: Bool { get set }
    
    var tabIndex: UInt8 { get set }
    
    var isVisible: Bool { get set }
    
    init(appService: AppService, url: String)
    
    func generateViewController() -> PageViewController
    
}

public extension Page {
    
    var title: String {
        if let title = style?.navigationBarTitleText {
            return title
        } else if let appService = appService,
                  let title = appService.config.window?.navigationBarTitleText {
            return title
        }
        return ""
    }
    
    var navigationBarBackgroundColor: UIColor {
        if let value = style?.navigationBarBackgroundColor, !value.isEmpty {
            return value.hexColor()
        } else if let appService = appService,
                  let value = appService.config.window?.navigationBarBackgroundColor,
                  !value.isEmpty {
            return value.hexColor()
        }
        return .white
    }
    
    var navigationBarTextStyle: UIColor {
        if let value = style?.navigationBarTextStyle {
            return value.toColor()
        } else if let appService = appService,
                  let value = appService.config.window?.navigationBarTextStyle {
            return value.toColor()
        }
        return .black
    }
    
    var navigationStyle: AppConfig.Style.NavigationStyle {
        if let value = style?.navigationStyle {
            return value
        } else if let appService = appService,
                  let value = appService.config.window?.navigationStyle {
            return value
        }
        return .default
    }
    
    var backgroundColor: UIColor {
        if let backgroundColor = style?.backgroundColor, !backgroundColor.isEmpty {
            return backgroundColor.hexColor()
        } else if let appService = appService,
                  let backgroundColor = appService.config.window?.backgroundColor,
                  !backgroundColor.isEmpty {
            return backgroundColor.hexColor()
        }
        return .white
    }
    
    func setTitle(_ title: String) {
        style?.navigationBarTitleText = title
        viewController?.navigationBar.setTitle(title)
    }
    
    func setNavigationBarTextStyle(_ style: AppConfig.Style.NavigationBarTextStyle) {
        self.style?.navigationBarTextStyle = style
        viewController?.navigationBar.color = style.toColor()
        viewController?.navigationBar.setBackIconColor(style)
        viewController?.setNeedsStatusBarAppearanceUpdate()
        appService?.uiControl.capsuleView.setColor(style)
    }
}
