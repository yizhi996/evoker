//
//  NZMiniProgramActionSheet.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public struct NZMiniProgramAction {
    let key: String
    let icon: String?
    let iconImage: UIImage?
    let title: String
}

class NZMiniProgramActionSheet: UIView, NZTransitionView {
    
    struct Params {
        let appId: String
        let appName: String
        let appIcon: String
        let firstActions: [NZMiniProgramAction]
        let secondActions: [NZMiniProgramAction]
    }
    
    var didSelectActionHandler: ((NZMiniProgramAction) -> Void)?
    var onCancel: NZEmptyBlock?
    
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
        let effectView = UIVisualEffectView.init(effect: effect)
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
        appNameLabel.textColor = "#000000".hexColor(alpha: 0.9)
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
        line.backgroundColor = "#000000".hexColor(alpha: 0.1)
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
        line2.backgroundColor = "#000000".hexColor(alpha: 0.1)
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
        cancelButton.setTitleColor("#000000".hexColor(alpha: 0.9), for: .normal)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                    left: 0,
                                                    bottom: Constant.safeAreaInsets.bottom,
                                                    right: 0)
        let whiteImage = UIImage.color(.white)
        cancelButton.setBackgroundImage(whiteImage, for: .normal)
        let hlImage = UIImage.color("#000000".hexColor(alpha: 0.1))
        cancelButton.setBackgroundImage(hlImage, for: .highlighted)
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
    
    func addActionItem(list: [NZMiniProgramAction], to scrollView: UIScrollView, section: Int) {
        var prev: MiniProgramActionSheetItemView?
        let spacing = 12.0
        let itemSize = 56.0
        
        for (i, item) in list.enumerated() {
            let actionView = MiniProgramActionSheetItemView()
            actionView.isUserInteractionEnabled = true
            actionView.action = item
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickAction(gesture:)))
            actionView.addGestureRecognizer(tapGesture)
            
            let actionButton = MiniProgramActionSheetItemButton()
            actionButton.action = item
            if let icon = item.iconImage {
                actionButton.setImage(icon, for: .normal)
            } else if let iconSrc = item.icon {
                actionButton.sd_setImage(with: URL(string: iconSrc), for: .normal, completed: nil)
            }
            actionButton.setBackgroundImage(UIImage(builtIn: "mp-action-sheet-button-bg"), for: .normal)
            actionButton.setBackgroundImage(UIImage(builtIn: "mp-action-sheet-button-bg-hl"), for: .highlighted)
            actionButton.addTarget(self, action: #selector(onClickAction(button:)), for: .touchUpInside)
            actionView.addSubview(actionButton)
            actionButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
            actionButton.autoSetDimension(.height, toSize: itemSize)
            
            let actionTitleLabel = UILabel()
            actionTitleLabel.text = item.title
            actionTitleLabel.numberOfLines = 0
            actionTitleLabel.textColor = "#000000".hexColor(alpha: 0.5)
            actionTitleLabel.font = UIFont.systemFont(ofSize: 10.0)
            actionTitleLabel.textAlignment = .center
            actionView.addSubview(actionTitleLabel)
            actionTitleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
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
        guard let button = button as? MiniProgramActionSheetItemButton, let action = button.action else { return }
        didSelectActionHandler?(action)
    }
    
    @objc func onClickAction(gesture: UIGestureRecognizer) {
        guard let view = gesture.view as? MiniProgramActionSheetItemView, let action = view.action else { return }
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

private class MiniProgramActionSheetItemView: UIView {
    
    var action: NZMiniProgramAction?
    
}

private class MiniProgramActionSheetItemButton: UIButton {
    
    var action: NZMiniProgramAction?
    
}
