//
//  NZTabBarItem.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import PureLayout

open class NZTabBarItem: UIButton {
    
    lazy var badgeView: NZBadgeView = {
        let badgeView = NZBadgeView()
        addSubview(badgeView)
        badgeView.autoPinEdge(toSuperviewEdge: .top, withInset: -3)
        badgeView.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 12.5)
        badgeView.autoSetDimension(.width, toSize: 50, relation: .lessThanOrEqual)
        return badgeView
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        let iconSize = 25.0
        
        let textSize = titleLabel!.frame.size
        let iconX = (bounds.width - iconSize) * 0.5
        let iconY = (bounds.height - iconSize - textSize.height) * 0.5
        imageView?.frame = CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize)
        
        let titleX = (bounds.width - textSize.width) * 0.5
        let titleY = imageView!.frame.maxY + 2
        titleLabel?.frame.origin = CGPoint(x: titleX,y: titleY)
    }
}

class NZBadgeView: UIImageView {
    
    lazy var redDotImage = UIImage(builtIn: "tab-bar-item-red-dot")
    
    lazy var badgeImage = UIImage(builtIn: "tab-bar-item-badge")
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    func showRedDot() {
        image = redDotImage
        textLabel.removeFromSuperview()
        isHidden = false
    }
    
    func hideRedDot() {
        isHidden = true
    }
    
    func showBadge(_ text: String) {
        image = badgeImage
        textLabel.text = text
        textLabel.removeFromSuperview()
        addSubview(textLabel)
        textLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 12)
        textLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 12)
        textLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 7.5)
        textLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 7.5)
        isHidden = false
    }
    
    func hideBadge() {
        textLabel.removeFromSuperview()
        isHidden = true
    }
}
