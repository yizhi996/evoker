//
//  CapsuleView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class CapsuleView: UIView {
    
    var clickCloseHandler: EmptyBlock?
    
    var clickMoreHandler: EmptyBlock?
    
    let moreButton = UIButton(type: .custom)
    
    let closeButton = UIButton(type: .custom)
    
    let buttonWidth: CGFloat = 43.3
    
    let buttonHeight: CGFloat = 32
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let moreIcon = UIImage.image(light: UIImage(builtIn: "mini-program-more-icon")!,
                                     dark: UIImage(builtIn: "mini-program-more-icon-dark")!)
        moreButton.setImage(moreIcon, for: .normal)
        addSubview(moreButton)
        moreButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)
        moreButton.autoSetDimensions(to: CGSize(width: buttonWidth, height: buttonHeight))
        
        let closeIcon = UIImage.image(light: UIImage(builtIn: "mini-program-close-icon")!,
                                      dark: UIImage(builtIn: "mini-program-close-icon-dark")!)
        closeButton.setImage(closeIcon, for: .normal)
        addSubview(closeButton)
        closeButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .left)
        closeButton.autoMatch(.width, to: .width, of: moreButton)
        closeButton.autoMatch(.height, to: .height, of: moreButton)
        closeButton.autoPinEdge(.left, to: .right, of: moreButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setColor(_ style: AppConfig.Style.NavigationBarTextStyle) {
        if style == .black {
            moreButton.setImage(UIImage(builtIn: "mini-program-more-icon"), for: .normal)
            closeButton.setImage(UIImage(builtIn: "mini-program-close-icon"), for: .normal)
        } else {
            moreButton.setImage(UIImage(builtIn: "mini-program-more-icon-dark"), for: .normal)
            closeButton.setImage(UIImage(builtIn: "mini-program-close-icon-dark"), for: .normal)
        }
    }
    
    func add(to view: UIView) {
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(showMore), for: .touchUpInside)
        view.addSubview(self)
        autoPinEdge(toSuperviewEdge: .top, withInset: Constant.statusBarHeight + (Constant.navigationBarHeight - buttonHeight) / 2)
        autoPinEdge(toSuperviewEdge: .right, withInset: 7)
    }
    
    @objc
    func close() {
        clickCloseHandler?()
    }
    
    @objc
    func showMore() {
        clickMoreHandler?()
    }
    
}
