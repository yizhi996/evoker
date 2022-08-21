//
//  AppMoreActionSheet.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public struct AppMoreAction {
    
    static let builtInShareKey = "builtin:share"
    
    static let builtInSettingsKey = "builtin:settings"
    
    static let builtInReLaunchKey = "builtin:reLaunch"
    
    /// 标识符
    let key: String
    
    /// 标题
    let title: String
    
    /// 是否允许点击
    let enable: Bool
    
    /// 图标地址
    let icon: String?
    
    /// 使用本地图片，优先级高于 icon
    let iconImage: UIImage?
    
    /// 禁用状态的图标地址
    let disabledIcon: String?
    
    /// 禁用状态的图片，使用本地图片，优先级高于 disabledIcon
    let disabledIconImage: UIImage?
    
    init(key: String,
         title: String,
         enable: Bool = true,
         icon: String? = nil,
         iconImage: UIImage? = nil,
         disabledIcon: String? = nil,
         disabledIconImage: UIImage? = nil) {
        self.key = key
        self.title = title
        self.enable = enable
        self.icon = icon
        self.iconImage = iconImage
        self.disabledIcon = disabledIcon
        self.disabledIconImage = disabledIconImage
    }
    
}

class AppMoreActionSheet: UIView, TransitionView {
    
    struct Params {
        let appId: String
        
        let appName: String
        
        let appIcon: String
        
        let firstActions: [AppMoreAction]
        
        let secondActions: [AppMoreAction]
    }
    
    var didSelectActionHandler: ((AppMoreAction) -> Void)?
    
    var onCancel: EmptyBlock?
    
    let appIconImageView = UIImageView()
    let appNameLabel = UILabel()
    
    let firstActionSheetView = UIScrollView()
    let secondActionSheetView = UIScrollView()
    let cancelButton = UIButton()
    
    init(params: Params) {
        super.init(frame: .zero)
        
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        
        let effect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.contentView.backgroundColor = UIColor.color("#f7f7f7".hexColor(alpha: 0.5), dark: "#191919".hexColor())
        addSubview(effectView)
        effectView.autoPinEdgesToSuperviewEdges()
        
        appIconImageView.layer.masksToBounds = true
        appIconImageView.layer.cornerRadius = 12.0
        appIconImageView.sd_setImage(with: URL(string: params.appIcon),
                                     placeholderImage: UIImage.color(.gray),
                                     completed: nil)
        addSubview(appIconImageView)
        appIconImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 16.0)
        appIconImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16.0)
        appIconImageView.autoSetDimensions(to: CGSize(width: 24, height: 24))
        
        appNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        appNameLabel.textColor = UIColor.color("#000".hexColor(alpha: 0.9), dark: "#fff".hexColor(alpha: 0.9))
        appNameLabel.text = params.appName
        addSubview(appNameLabel)
        appNameLabel.autoPinEdge(.left, to: .right, of: appIconImageView, withOffset: 10.0)
        appNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: appIconImageView)
        
        let appInfoButton = UIButton()
        appInfoButton.addTarget(self, action: #selector(onClickToAppInfo), for: .touchUpInside)
        addSubview(appInfoButton)
        appInfoButton.autoPinEdge(.left, to: .left, of: appIconImageView)
        appInfoButton.autoPinEdge(.right, to: .right, of: appNameLabel)
        appInfoButton.autoPinEdge(.top, to: .top, of: appIconImageView)
        appInfoButton.autoPinEdge(.bottom, to: .bottom, of: appIconImageView)
        
        let line = UIView()
        line.backgroundColor = UIColor.color("#000".hexColor(alpha: 0.1), dark: "#fff".hexColor(alpha: 0.05))
        addSubview(line)
        line.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        line.autoPinEdge(toSuperviewEdge: .right, withInset: 12.0)
        line.autoPinEdge(.top, to: .bottom, of: appInfoButton, withOffset: 16.0)
        line.autoSetDimension(.height, toSize: 1 / Constant.scale)
        
        firstActionSheetView.isScrollEnabled = true
        firstActionSheetView.alwaysBounceVertical = false
        firstActionSheetView.alwaysBounceHorizontal = true
        firstActionSheetView.showsHorizontalScrollIndicator = false
        firstActionSheetView.contentInset = UIEdgeInsets(top: 0, left: 12.0, bottom: 0, right: 12.0)
        addSubview(firstActionSheetView)
        firstActionSheetView.autoPinEdge(toSuperviewEdge: .left)
        firstActionSheetView.autoPinEdge(toSuperviewEdge: .right)
        firstActionSheetView.autoPinEdge(.top, to: .bottom, of: line, withOffset: 16.0)
        firstActionSheetView.autoSetDimension(.height, toSize: 108)
        
        let line2 = UIView()
        line2.backgroundColor = UIColor.color("#000".hexColor(alpha: 0.1), dark: "#fff".hexColor(alpha: 0.05))
        addSubview(line2)
        line2.autoPinEdge(toSuperviewEdge: .left, withInset: 12.0)
        line2.autoPinEdge(toSuperviewEdge: .right, withInset: 12.0)
        line2.autoPinEdge(.top, to: .bottom, of: firstActionSheetView)
        line2.autoSetDimension(.height, toSize: 1 / Constant.scale)
        
        secondActionSheetView.isScrollEnabled = true
        secondActionSheetView.alwaysBounceVertical = false
        secondActionSheetView.alwaysBounceHorizontal = true
        secondActionSheetView.showsHorizontalScrollIndicator = false
        secondActionSheetView.contentInset = UIEdgeInsets(top: 0, left: 12.0, bottom: 0, right: 12.0)
        addSubview(secondActionSheetView)
        secondActionSheetView.autoPinEdge(toSuperviewEdge: .left)
        secondActionSheetView.autoPinEdge(toSuperviewEdge: .right)
        secondActionSheetView.autoPinEdge(.top, to: .bottom, of: line2, withOffset: 16.0)
        secondActionSheetView.autoSetDimension(.height, toSize: 108)
        
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        cancelButton.setTitleColor(UIColor.color("#000".hexColor(alpha: 0.9),
                                                 dark: "#fff".hexColor(alpha: 0.9)), for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                    left: 0,
                                                    bottom: Constant.safeAreaInsets.bottom,
                                                    right: 0)
        let cancelBackgroundImage = UIImage.image(light: UIImage.color(.white)!,
                                                  dark: UIImage.color("#2c2c2c".hexColor())!)
        cancelButton.setBackgroundImage(cancelBackgroundImage, for: .normal)
        let cancelBackgroundHighlightImage = UIImage.image(light: UIImage.color("#000".hexColor(alpha: 0.1))!,
                                                           dark: UIImage.color("#fff".hexColor(alpha: 0.1))!)
        cancelButton.setBackgroundImage(cancelBackgroundHighlightImage, for: .highlighted)
        cancelButton.addTarget(self, action: #selector(onClickCancel), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.autoSetDimension(.height, toSize: 56.0 + Constant.safeAreaInsets.bottom)
        cancelButton.autoPinEdge(.top, to: .bottom, of: secondActionSheetView)
        cancelButton.autoPinEdge(toSuperviewEdge: .left)
        cancelButton.autoPinEdge(toSuperviewEdge: .right)
        cancelButton.autoPinEdge(toSuperviewEdge: .bottom)
        
        addActionItem(list: params.firstActions, to: firstActionSheetView, section: 0)
        addActionItem(list: params.secondActions, to: secondActionSheetView, section: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addActionItem(list: [AppMoreAction], to scrollView: UIScrollView, section: Int) {
        var prev: AppMoreActionSheetItemView?
        let spacing = 12.0
        let itemSize = 56.0
        
        for (i, item) in list.enumerated() {
            let actionView = AppMoreActionSheetItemView()
            actionView.isUserInteractionEnabled = item.enable
            actionView.action = item
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickAction(gesture:)))
            actionView.addGestureRecognizer(tapGesture)
            
            let actionButton = AppMoreActionSheetItemButton()
            actionButton.action = item
            actionButton.isEnabled = item.enable
            
            if let icon = item.iconImage {
                actionButton.setImage(icon, for: .normal)
            } else if let src = item.icon {
                actionButton.sd_setImage(with: URL(string: src), for: .normal, completed: nil)
            }
            
            if let icon = item.disabledIconImage {
                actionButton.setImage(icon, for: .disabled)
            } else if let src = item.disabledIcon {
                actionButton.sd_setImage(with: URL(string: src), for: .disabled, completed: nil)
            }
            
            let backgroundImage = UIImage.image(light: UIImage(builtIn: "mp-action-sheet-button-bg")!,
                                                dark: UIImage(builtIn: "mp-action-sheet-button-bg-dark")!)
            actionButton.setBackgroundImage(backgroundImage, for: .normal)
            let backgroundHighlightImage = UIImage.image(light:UIImage(builtIn: "mp-action-sheet-button-bg-hl")!,
                                                         dark: UIImage(builtIn: "mp-action-sheet-button-bg-hl-dark")!)
            actionButton.setBackgroundImage(backgroundHighlightImage, for: .highlighted)
            actionButton.addTarget(self, action: #selector(onClickAction(button:)), for: .touchUpInside)
            actionView.addSubview(actionButton)
            actionButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            actionButton.autoSetDimension(.height, toSize: itemSize)
            
            let actionTitleLabel = UILabel()
            actionTitleLabel.text = item.title
            actionTitleLabel.numberOfLines = 0
            actionTitleLabel.textColor = UIColor.color("#000".hexColor(alpha: 0.5),
                                                       dark: "#fff".hexColor(alpha: 0.5))
            actionTitleLabel.font = UIFont.systemFont(ofSize: 10.0)
            actionTitleLabel.textAlignment = .center
            actionView.addSubview(actionTitleLabel)
            actionTitleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            actionTitleLabel.autoPinEdge(toSuperviewEdge: .left)
            actionTitleLabel.autoPinEdge(toSuperviewEdge: .right)
            actionTitleLabel.autoPinEdge(.top, to: .bottom, of: actionButton, withOffset: 8.0)
            
            scrollView.addSubview(actionView)
            if let prev = prev {
                actionView.autoPinEdge(.left, to: .right, of: prev, withOffset: spacing)
            } else {
                actionView.autoPinEdge(toSuperviewEdge: .left)
            }
            if i == list.count - 1 {
                actionView.autoPinEdge(toSuperviewEdge: .right)
            }
            actionView.autoPinEdge(toSuperviewEdge: .top)
            actionView.autoSetDimensions(to: CGSize(width: itemSize, height: 98))
            prev = actionView
        }
        scrollView.contentSize = CGSize(width: CGFloat(list.count) * (itemSize + spacing), height: 108)
        scrollView.contentOffset = CGPoint(x: -spacing, y: 0)
    }
    
    @objc func onClickToAppInfo() {
        
    }
    
    @objc func onClickAction(button: UIButton) {
        guard let button = button as? AppMoreActionSheetItemButton, let action = button.action else { return }
        didSelectActionHandler?(action)
    }
    
    @objc func onClickAction(gesture: UIGestureRecognizer) {
        guard let view = gesture.view as? AppMoreActionSheetItemView, let action = view.action else { return }
        didSelectActionHandler?(action)
    }
    
    @objc func onClickCancel() {
        onCancel?()
    }
    
    func show(to view: UIView) {
        view.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        popup()
    }
    
    func hide() {
        popdown() {
            self.removeFromSuperview()
        }
    }
}

private class AppMoreActionSheetItemView: UIView {
    
    var action: AppMoreAction?
    
}

private class AppMoreActionSheetItemButton: UIButton {
    
    var action: AppMoreAction?
    
}
