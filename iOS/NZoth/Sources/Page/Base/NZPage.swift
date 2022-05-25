//
//  NZPage.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol NZPage: AnyObject {
    
    var pageId: Int { get }
    
    var url: String { get }
    
    var appService: NZAppService? { get set }
    
    var viewController: NZPageViewController? { get set }
    
    var style: NZPageStyle? { get set }
    
    var isTabBarPage: Bool { get set }
    
    var isShowTabBar: Bool { get set }
    
    var isVisible: Bool { get set }
    
    init(appService: NZAppService, url: String)
    
    func generateViewController() -> NZPageViewController
    
}

public extension NZPage {
    
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
    
    var navigationStyle: NZPageStyle.NavigationStyle {
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
    
    func setNavigationBarTextStyle(_ style: NZPageStyle.NavigationBarTextStyle) {
        self.style?.navigationBarTextStyle = style
        viewController?.navigationBar.color = style.toColor()
        viewController?.navigationBar.setBackIconColor(style)
        viewController?.setNeedsStatusBarAppearanceUpdate()
        appService?.uiControl.capsuleView.setColor(style)
    }
}
