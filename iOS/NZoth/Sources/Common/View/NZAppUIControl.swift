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
    
    public var gotoHomeHandler: NZEmptyBlock?
    
    public var closeHandler: NZEmptyBlock?
    
    public var showAppMoreActionBoardHandler: NZEmptyBlock?
    
    public var didSelectTabBarIndexHandler: NZIntBlock?
    
    private let capsuleView = NZCapsuleView()
    
    public lazy var tabBarView = NZTabBarView()
    
    public lazy var tabBarViewControllers: [String: NZPageViewController] = [:]
    
    public internal(set) var gotoHomeButton: UIButton?
    
    public func setupTabBar(config: NZAppConfig, envVersion: NZAppEnvVersion) {
        if let tabBarInfo = config.tabBar, !tabBarInfo.list.isEmpty {
            tabBarView.backgroundColor = tabBarInfo.backgroundColor.hexColor()
            tabBarView.load(config: config, envVersion: envVersion)
            tabBarView.didSelectIndex = { [unowned self] index in
                self.didSelectTabBarIndexHandler?(index)
            }
        }
    }
    
    public func addTabBar(to view: UIView) {
        guard tabBarView.superview != view else { return }
        tabBarView.removeFromSuperview()
        let height = Constant.tabBarHeight
        tabBarView.frame = CGRect(x: 0, y: view.frame.height - height, width: view.frame.width, height: height)
        view.addSubview(tabBarView)
    }
    
    public func addGotoHomeButton(to view: UIView) {
        let homeIcon = UIImage(builtIn: "mini-program-home-icon")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton()
        button.setImage(homeIcon, for: .normal)
        button.addTarget(self, action: #selector(gotoHomePage), for: .touchUpInside)
        view.addSubview(button)
        let safeAreaTop = Constant.safeAreaInsets.top
        let buttonSize = 32.0
        let top = safeAreaTop + (Constant.navigationBarHeight - buttonSize) / 2
        button.autoPinEdge(toSuperviewEdge: .top, withInset: top)
        button.autoPinEdge(toSuperviewEdge: .left, withInset: 7)
        button.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))
        
        gotoHomeButton = button
    }
    
    public func removeGotoHomeButton() {
        gotoHomeButton?.removeFromSuperview()
        gotoHomeButton = nil
    }
    
    public func addCapsuleView(to view: UIView) {
        capsuleView.closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        capsuleView.moreButton.addTarget(self, action: #selector(clickShowAppMoreActionBoard), for: .touchUpInside)
        view.addSubview(capsuleView)
        capsuleView.autoPinEdge(toSuperviewSafeArea: .top,
                                withInset:  (Constant.navigationBarHeight - capsuleView.buttonHeight) / 2)
        capsuleView.autoPinEdge(toSuperviewEdge: .right, withInset: 7)
    }
    
    public func showAppMoreActionBoard(appId: String, appInfo: NZAppInfo, to view: UIView, didSelectHandler: @escaping NZStringBlock) {
        let firstActions: [NZMiniProgramAction] = []
        let settingIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-setting-icon")!,
                                             dark: UIImage(builtIn: "mp-action-sheet-setting-icon-dark")!)
        let settingsAction = NZMiniProgramAction(key: "settings",
                                                 icon: nil,
                                                 iconImage: settingIconImage,
                                                 title: "设置")
        let relaunchIconImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-reload-icon")!,
                                              dark: UIImage(builtIn: "mp-action-sheet-reload-icon-dark")!)
        let relaunchAction = NZMiniProgramAction(key: "relaunch",
                                                 icon: nil,
                                                 iconImage: relaunchIconImage,
                                                 title: "重新进入小程序")
        let secondActions = [settingsAction, relaunchAction]
        let params = NZMiniProgramActionSheet.Params(appId: appId,
                                                     appName: appInfo.appName,
                                                     appIcon: appInfo.appIconURL,
                                                     firstActions: firstActions,
                                                     secondActions: secondActions)
        let actionSheet = NZMiniProgramActionSheet(params: params)
        let cover = NZCoverView(contentView: actionSheet)
        let onHide: NZStringBlock = { key in
            cover.hide()
            didSelectHandler(key)
        }
        cover.clickHandler = {
            onHide("cancel")
        }
        actionSheet.didSelectActionHandler = { action in
            onHide(action.key)
        }
        actionSheet.onCancel = {
            onHide("cancel")
        }
        view.endEditing(true)
        cover.show(to: view)
    }
    
    public func showCapsule() {
        capsuleView.isHidden = false
    }
    
    public func hideCapsule() {
        capsuleView.isHidden = true
    }
    
    @objc private func close() {
        closeHandler?()
    }
    
    @objc private func gotoHomePage() {
        gotoHomeHandler?()
    }
    
    @objc private func clickShowAppMoreActionBoard() {
        showAppMoreActionBoardHandler?()
    }
}
