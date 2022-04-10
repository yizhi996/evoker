//
//  NZAuthorizationView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import SDWebImage

class NZAuthorizationView: UIView, NZTransitionView {
    
    struct Params: Decodable {
        let appName: String
        let appIcon: String
        let title: String
    }
    
    var completionHandler: NZBoolBlock?
    
    let appIconImageView = UIImageView()
    
    let appNameLabel = UILabel()
    
    let titleLabel = UILabel()
    
    let denyButton = UIButton()
    
    let acceptButton = UIButton()
    
    let customView = UIView()
    
    init(params: Params) {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        layer.cornerRadius = 12.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.masksToBounds = true
        
        appIconImageView.layer.masksToBounds = true
        appIconImageView.layer.cornerRadius = 12.0
        appIconImageView.sd_setImage(with: URL(string: params.appIcon),
                                     placeholderImage: UIImage.color(.gray),
                                     completed: nil)
        addSubview(appIconImageView)
        appIconImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 16.0)
        appIconImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 16.0)
        appIconImageView.autoSetDimensions(to: CGSize(width: 24, height: 24))
        
        appNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        appNameLabel.textColor = "#000000".hexColor(alpha: 0.9)
        appNameLabel.text = params.appName
        addSubview(appNameLabel)
        appNameLabel.autoPinEdge(.left, to: .right, of: appIconImageView, withOffset: 10.0)
        appNameLabel.autoAlignAxis(.horizontal, toSameAxisOf: appIconImageView)
        
        let requireLabel = UILabel()
        requireLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        requireLabel.textColor = "#000000".hexColor(alpha: 0.9)
        requireLabel.text = "申请"
        addSubview(requireLabel)
        requireLabel.autoPinEdge(.left, to: .right, of: appNameLabel, withOffset: 5.0)
        requireLabel.autoAlignAxis(.horizontal, toSameAxisOf: appNameLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        titleLabel.textColor = "#000000".hexColor(alpha: 0.9)
        titleLabel.text = params.title
        addSubview(titleLabel)
        titleLabel.autoPinEdge(.left, to: .left, of: appIconImageView)
        titleLabel.autoPinEdge(.top, to: .bottom, of: appIconImageView, withOffset: 24.0)
        
        addSubview(customView)
        customView.autoAlignAxis(toSuperviewAxis: .vertical)
        customView.autoPinEdge(.top, to: .bottom, of: titleLabel)
        
        let actionView = UIView()
        addSubview(actionView)
        actionView.autoPinEdge(.top, to: .bottom, of: customView, withOffset: 40)
        actionView.autoAlignAxis(toSuperviewAxis: .vertical)
        actionView.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 30)
        
        denyButton.layer.cornerRadius = 4.0
        denyButton.layer.masksToBounds = true
        denyButton.setTitle("拒绝", for: .normal)
        denyButton.setTitleColor("#1989fa".hexColor(), for: .normal)
        denyButton.setBackgroundImage(UIImage.color("#eeeeee".hexColor()), for: .normal)
        denyButton.setBackgroundImage(UIImage.color("#000000".hexColor(alpha: 0.1)), for: .highlighted)
        denyButton.addTarget(self, action: #selector(clickCancel), for: .touchUpInside)
        actionView.addSubview(denyButton)
        denyButton.autoSetDimensions(to: CGSize(width: 120, height: 40))
        denyButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)
        
        acceptButton.layer.cornerRadius = 4.0
        acceptButton.layer.masksToBounds = true
        acceptButton.setTitle("允许", for: .normal)
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.setBackgroundImage(UIImage.color("#1989fa".hexColor()), for: .normal)
        acceptButton.setBackgroundImage(UIImage.color("#000000".hexColor(alpha: 0.1)), for: .highlighted)
        acceptButton.addTarget(self, action: #selector(clickAccept), for: .touchUpInside)
        actionView.addSubview(acceptButton)
        acceptButton.autoSetDimensions(to: CGSize(width: 120, height: 40))
        acceptButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .left)
        acceptButton.autoPinEdge(.left, to: .right, of: denyButton, withOffset: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    @objc func clickCancel() {
        completionHandler?(false)
    }
    
    @objc func clickAccept() {
        completionHandler?(true)
    }
}
