//
//  LoadingView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class LoadingView: UIView {
    
    var circleLayer: CAShapeLayer!
    
    let circleView = UIView()
    
    let iconView = UIImageView()
    
    init(appInfo: AppInfo) {
        super.init(frame: .zero)
        
        let iconSize: CGFloat = 96
        
        backgroundColor = .white
        iconView.sd_setImage(with: URL(string: appInfo.appIconURL))
        iconView.layer.cornerRadius = iconSize * 0.5
        addSubview(iconView)
        iconView.autoSetDimensions(to: CGSize(width: iconSize, height: iconSize))
        iconView.autoAlignAxis(toSuperviewAxis: .vertical)
        iconView.autoAlignAxis(.horizontal, toSameAxisOf: self, withOffset: -88)
        
        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        nameLabel.text = appInfo.appName
        addSubview(nameLabel)
        nameLabel.autoPinEdge(.top, to: .bottom, of: iconView, withOffset: 16)
        nameLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        
        addSubview(circleView)
        circleView.autoMatch(.width, to: .width, of: iconView)
        circleView.autoMatch(.height, to: .height, of: iconView)
        circleView.autoAlignAxis(.horizontal, toSameAxisOf: iconView)
        circleView.autoAlignAxis(.vertical, toSameAxisOf: iconView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if circleLayer == nil {
            circleLayer = CAShapeLayer()
            let radius: CGFloat = circleView.frame.width * 0.5
            circleLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                                y: 0,
                                                                width: radius * 2,
                                                                height: radius * 2), cornerRadius: radius).cgPath
            
            circleLayer.position = .zero
            circleLayer.strokeColor = "#f7f7f7".hexColor().cgColor
            circleLayer.lineWidth = 2
            circleLayer.fillColor = .none
            circleLayer.contentsScale = UIScreen.main.scale
            circleView.layer.addSublayer(circleLayer)
            
            let ballLayer = CAShapeLayer()
            let ballRadius: CGFloat = 6
            ballLayer.path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                              y: 0,
                                                              width: ballRadius * 2,
                                                              height: ballRadius * 2), cornerRadius: ballRadius).cgPath
            ballLayer.position = CGPoint(x: -ballRadius, y: radius - ballRadius)
            ballLayer.strokeColor = UIColor.white.cgColor
            ballLayer.lineWidth = 2
            ballLayer.fillColor = "#1989fa".hexColor().cgColor
            ballLayer.contentsScale = UIScreen.main.scale
            circleLayer.addSublayer(ballLayer)

            circleView.rotation()
        }
    }
}
