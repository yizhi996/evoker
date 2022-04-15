//
//  NZNavigationBar.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZNavigationBar: UIView {
    
    private let titleLabel = UILabel()
    
    private var backButton: UIButton?
    
    private var onBackHandler: NZEmptyBlock?
    
    private lazy var loadingImage: UIImageView = {
        let img = UIImage(builtIn: "navigation-loading")
        let imageView = UIImageView(image: img)
        addSubview(imageView)
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
        addSubview(button)
        let safeAreaTop = Constant.safeAreaInsets.top
        let buttonSize = 32.0
        let top = safeAreaTop + (Constant.navigationBarHeight - buttonSize) / 2
        button.autoPinEdge(toSuperviewEdge: .top, withInset: top)
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
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = color
        addSubview(titleLabel)
        
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoSetDimension(.height, toSize: 20)
        titleLabel.autoPinEdge(toSuperviewSafeArea: .top, withInset: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackButton(_ handler: @escaping NZEmptyBlock) {
        onBackHandler = handler
        guard backButton == nil else { return }
        let backIcon = UIImage(builtIn: "back-arrow-icon")
        backButton = UIButton()
        backButton!.imageView?.tintColor = color
        backButton!.setImage(backIcon, for: .normal)
        backButton!.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        addSubview(backButton!)
        
        backButton!.autoSetDimensions(to: CGSize(width: 24, height: 44))
        backButton!.autoPinEdge(toSuperviewEdge: .left, withInset: 15)
        backButton!.autoPinEdge(toSuperviewSafeArea: .top)
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
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
        NZEngine.shared.currentApp?.gotoHomePage()
    }
    
}
