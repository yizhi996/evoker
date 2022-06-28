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
        
        func builtInItems() -> [AppMoreAction] {
            let settingIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-setting-icon")!,
                                                 dark: UIImage(builtIn: "mp-action-sheet-setting-icon-dark")!)
            let settingsAction = AppMoreAction(key: AppMoreAction.builtInSettingsKey,
                                                     icon: nil,
                                                     iconImage: settingIconImage,
                                                     title: "设置")
            let relaunchIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-reload-icon")!,
                                                  dark: UIImage(builtIn: "mp-action-sheet-reload-icon-dark")!)
            let relaunchAction = AppMoreAction(key: AppMoreAction.builtInReLaunchKey,
                                                     icon: nil,
                                                     iconImage: relaunchIconImage,
                                                     title: "重新进入小程序")
            return [settingsAction, relaunchAction]
        }
        
        let firstActions: [AppMoreAction]
        let secondActions: [AppMoreAction]
        if let data = Engine.shared.config.hooks.app.fetchAppMoreActionSheetItems?(appService) {
            firstActions = data.0
            if data.2 {
                secondActions = builtInItems() + data.1
            } else {
                secondActions = data.1
            }
        } else {
            firstActions = []
            secondActions = builtInItems()
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
