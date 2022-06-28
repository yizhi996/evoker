//
//  ScanCodeView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class ScanCodeView: UIView {
    
    let tipLabel = UILabel()
    let openAlbumButton = UIButton()
    let backButton = UIButton()
    let scanEffectView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        backButton.setBackgroundImage(UIImage(builtIn: "back-arrow-icon-circle-dark"), for: .normal)
        addSubview(backButton)
        backButton.autoPinEdge(toSuperviewEdge: .left, withInset: 24)
        backButton.autoPinEdge(toSuperviewEdge: .top, withInset: Constant.statusBarHeight + 8)
        backButton.autoSetDimensions(to: CGSize(width: 28, height: 28))
        
        openAlbumButton.setImage(UIImage(builtIn: "album-icon"), for: .normal)
        openAlbumButton.backgroundColor = "#000000".hexColor(alpha: 0.3)
        openAlbumButton.layer.cornerRadius = 24
        openAlbumButton.layer.masksToBounds = true
        addSubview(openAlbumButton)
        openAlbumButton.autoPinEdge(toSuperviewEdge: .bottom, withInset: 66)
        openAlbumButton.autoPinEdge(toSuperviewEdge: .right, withInset: 24)
        openAlbumButton.autoSetDimensions(to: CGSize(width: 48, height: 48))
        
        tipLabel.text = "扫二维码 / 条码"
        tipLabel.textColor = "#ffffff".hexColor(alpha: 0.7)
        tipLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        addSubview(tipLabel)
        tipLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        tipLabel.autoPinEdge(.bottom, to: .top, of: openAlbumButton, withOffset: -48)
        
        scanEffectView.isHidden = true
        scanEffectView.image = UIImage(builtIn: "scan-effect-img")
        addSubview(scanEffectView)
        scanEffectView.autoPinEdge(toSuperviewEdge: .left)
        scanEffectView.autoPinEdge(toSuperviewEdge: .right)
        scanEffectView.autoPinEdge(toSuperviewEdge: .top)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let superview = superview else { return }
        
        let begin = (superview.frame.height - superview.frame.width) * 0.5
        scanEffectView.translationY(duration: 2.0, from: begin, to: begin + superview.frame.width)
    }
}
