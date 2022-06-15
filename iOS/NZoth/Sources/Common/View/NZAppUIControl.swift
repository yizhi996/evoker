//
//  NZAppUIControl.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import PureLayout

public class NZAppUIControl {
    
    let capsuleView = NZCapsuleView()
    
    lazy var tabBarView = NZTabBarView()
    
    lazy var tabBarViewControllers: [String: NZPageViewController] = [:]
    
    public func showCapsule() {
        capsuleView.isHidden = false
    }
    
    public func hideCapsule() {
        capsuleView.isHidden = true
    }
    
    public func showAppMoreActionBoard(appService: NZAppService,
                                       to view: UIView,
                                       cancellationHandler: NZEmptyBlock?,
                                       selectionHandler: @escaping (NZAppMoreActionItem) -> Void) {
        
        func builtInItems() -> [NZAppMoreActionItem] {
            let settingIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-setting-icon")!,
                                                 dark: UIImage(builtIn: "mp-action-sheet-setting-icon-dark")!)
            let settingsAction = NZAppMoreActionItem(key: NZAppMoreActionItem.builtInSettingsKey,
                                                     icon: nil,
                                                     iconImage: settingIconImage,
                                                     title: "设置")
            let relaunchIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-reload-icon")!,
                                                  dark: UIImage(builtIn: "mp-action-sheet-reload-icon-dark")!)
            let relaunchAction = NZAppMoreActionItem(key: NZAppMoreActionItem.builtInReLaunchKey,
                                                     icon: nil,
                                                     iconImage: relaunchIconImage,
                                                     title: "重新进入小程序")
            return [settingsAction, relaunchAction]
        }
        
        let firstActions: [NZAppMoreActionItem]
        let secondActions: [NZAppMoreActionItem]
        if let data = NZEngineConfig.shared.hooks.app.fetchAppMoreActionSheetItems?(appService) {
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
        
        let params = NZAppMoreActionSheet.Params(appId: appService.appId,
                                                 appName: appService.appInfo.appName,
                                                 appIcon: appService.appInfo.appIconURL,
                                                 firstActions: firstActions,
                                                 secondActions: secondActions)
        let actionSheet = NZAppMoreActionSheet(params: params)
        let cover = NZCoverView(contentView: actionSheet)
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
