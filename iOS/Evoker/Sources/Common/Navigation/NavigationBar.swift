//
//  NavigationBar.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NavigationBar: UIView {
    
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    
    private var backButton: UIButton?
    
    private var onBackHandler: EmptyBlock?
    
    private lazy var loadingImage: UIImageView = {
        let img = UIImage(builtIn: "navigation-loading")
        let imageView = UIImageView(image: img)
        contentView.addSubview(imageView)
        imageView.autoSetDimensions(to: CGSize(width: 16, height: 16))
        imageView.autoPinEdge(.right, to: .left, of: titleLabel, withOffset: -4)
        imageView.autoAlignAxis(.horizontal, toSameAxisOf: titleLabel)
        
        imageView.rotation()
        return imageView
    }()
    
    private lazy var gotoHomeButton: UIButton = {
        let homeIcon = UIImage(builtIn: "mini-program-home-icon")?.withRenderingMode(.alwaysOriginal)
        let button = UIButton()
        button.setImage(homeIcon, for: .normal)
        button.addTarget(self, action: #selector(gotoHomePage), for: .touchUpInside)
        contentView.addSubview(button)
        let buttonSize = 32.0
        button.autoAlignAxis(toSuperviewAxis: .horizontal)
        button.autoPinEdge(toSuperviewEdge: .left, withInset: 7)
        button.autoSetDimensions(to: CGSize(width: buttonSize, height: buttonSize))
        return button
    }()
    
    var isLoading: Bool = false {
        didSet {
            loadingImage.isHidden = !isLoading
        }
    }
    
    var color: UIColor = .black {
        didSet {
            titleLabel.textColor = color
            if let backButton = backButton {
                backButton.imageView?.tintColor = color
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        contentView.autoSetDimension(.height, toSize: Constant.navigationBarHeight)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = color
        contentView.addSubview(titleLabel)
        
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackButton(_ handler: @escaping EmptyBlock) {
        onBackHandler = handler
        guard backButton == nil else { return }
        let backIcon = UIImage.image(light: UIImage(builtIn: "back-arrow-icon")!,
                                     dark: UIImage(builtIn: "back-arrow-icon-dark")!)
        backButton = UIButton()
        backButton!.imageView?.tintColor = color
        backButton!.setImage(backIcon, for: .normal)
        backButton!.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        contentView.addSubview(backButton!)
        
        backButton!.autoSetDimensions(to: CGSize(width: 24, height: 44))
        backButton!.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        backButton!.autoAlignAxis(toSuperviewAxis: .horizontal)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setBackIconColor(_ style: AppConfig.Style.NavigationBarTextStyle) {
        var icon: UIImage?
        if style == .white {
            icon = UIImage(builtIn: "back-arrow-icon-dark")
        } else {
            icon = UIImage(builtIn: "back-arrow-icon")
        }
        backButton?.setImage(icon, for: .normal)
    }
    
    func showGotoHomeButton() {
        gotoHomeButton.isHidden = false
    }
    
    func hideGotoHomeButton() {
        gotoHomeButton.isHidden = true
    }
    
    @objc
    private func onBack() {
        onBackHandler?()
    }
    
    @objc
    func gotoHomePage() {
        Engine.shared.currentApp?.gotoHomePage()
    }
    
}
