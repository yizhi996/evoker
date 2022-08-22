//
//  AppUIControl.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import PureLayout

public class AppUIControl {
    
    let capsuleView = CapsuleView()
    
    lazy var tabBarView = TabBarView()
    
    lazy var tabBarViewControllers: [String: PageViewController] = [:]
    
    public func showCapsule() {
        capsuleView.isHidden = false
    }
    
    public func hideCapsule() {
        capsuleView.isHidden = true
    }
    
    public func showAppMoreActionBoard(appService: AppService,
                                       to view: UIView,
                                       cancellationHandler: EmptyBlock?,
                                       selectionHandler: @escaping (AppMoreAction) -> Void) {
        var enableShare = false
        if let webPage = appService.currentPage as? WebPage {
            enableShare = webPage.shareEnable
        }
        
        func firstBuiltInItems() -> [AppMoreAction] {
            let settingIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-share-icon")!,
                                                 dark: UIImage(builtIn: "mp-action-sheet-share-icon-dark")!)
            let shareAction = AppMoreAction(key: AppMoreAction.builtInShareKey,
                                            title: enableShare ? "转发" : "当前页面不能转发",
                                            enable: enableShare,
                                            iconImage: settingIconImage,
                                            disabledIconImage: nil)
            return [shareAction]
        }
        
        func secondBuiltInItems() -> [AppMoreAction] {
            let settingIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-setting-icon")!,
                                                 dark: UIImage(builtIn: "mp-action-sheet-setting-icon-dark")!)
            let settingsAction = AppMoreAction(key: AppMoreAction.builtInSettingsKey,
                                               title: "设置",
                                               iconImage: settingIconImage)
            let relaunchIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-reload-icon")!,
                                                  dark: UIImage(builtIn: "mp-action-sheet-reload-icon-dark")!)
            let relaunchAction = AppMoreAction(key: AppMoreAction.builtInReLaunchKey,
                                               title: "重新进入\n小程序",
                                               iconImage: relaunchIconImage)
            return [settingsAction, relaunchAction]
        }
        
        
        let firstActions: [AppMoreAction]
        let secondActions: [AppMoreAction]
        if let data = Engine.shared.config.hooks.app.fetchAppMoreActionSheetItems?(appService) {
            firstActions = firstBuiltInItems() + data.0
            if data.2 {
                secondActions = secondBuiltInItems() + data.1
            } else {
                secondActions = data.1
            }
        } else {
            firstActions = firstBuiltInItems()
            secondActions = secondBuiltInItems()
        }
        
        let params = AppMoreActionSheet.Params(appId: appService.appId,
                                               appName: appService.appInfo.appName,
                                               appIcon: appService.appInfo.appIconURL,
                                               firstActions: firstActions,
                                               secondActions: secondActions)
        let actionSheet = AppMoreActionSheet(params: params)
        let cover = CoverView(contentView: actionSheet)
        cover.clickHandler = {
            cover.hide()
            cancellationHandler?()
        }
        actionSheet.didSelectActionHandler = { action in
            cover.hide()
            selectionHandler(action)
        }
        actionSheet.onCancel = {
            cover.hide()
            cancellationHandler?()
        }
        cover.show(to: view)
    }
    
}
