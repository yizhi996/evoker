//
//  Toast.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class Toast: UIView, TransitionView {
    
    struct Params: Decodable {
        let title: String
        let icon: Icon
        let image: String?
        let duration: Int
        let mask: Bool
    }
    
    enum Icon: String, Decodable {
        case success
        case error
        case loading
        case none
    }
    
    static var global: Toast?
    
    let params: Params
    
    let borderView = UIView()
    lazy var titleLabel = UILabel()
    lazy var iconImageView = UIImageView()
    
    init(params: Params, appService: AppService? = nil) {
        self.params = params
        super.init(frame: .zero)
        
        isUserInteractionEnabled = params.mask
        
        borderView.alpha = 0
        borderView.backgroundColor = "#4c4c4c".hexColor()
        borderView.layer.masksToBounds = true
        borderView.layer.cornerRadius = 12.0
        addSubview(borderView)
        borderView.autoCenterInSuperview()
        
        var image: UIImage?
        if let customImagePath = params.image, let appService = appService {
            let url = FilePath.appStaticFilePath(appService: appService, src: customImagePath)
            image = UIImage(contentsOfFile: url.path)
        } else if params.icon != .none {
            switch params.icon {
            case .success:
                image = UIImage(builtIn: "hud-success-icon")
            case .error:
                image = UIImage(builtIn: "hud-error-icon")
            case .loading:
                image = UIImage(builtIn: "hud-loading-icon")
            default:
                break
            }
        }
        
        if let image = image {
            iconImageView.image = image
            borderView.addSubview(iconImageView)
            
            if params.icon == .loading {
                iconImageView.rotation()
            }
            
            iconImageView.autoSetDimensions(to: CGSize(width: 40, height: 40))
            iconImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            iconImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 28)
            
            if params.title.isEmpty {
                iconImageView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 28)
                iconImageView.autoPinEdge(toSuperviewEdge: .left, withInset: 28)
                iconImageView.autoPinEdge(toSuperviewEdge: .right, withInset: 28)
            }
        }
        
        if !params.title.isEmpty {
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
            titleLabel.text = params.title
            borderView.addSubview(titleLabel)
            if image != nil {
                titleLabel.font = UIFont.systemFont(ofSize: 17)
                titleLabel.numberOfLines = 2
                titleLabel.autoPinEdge(.top, to: .bottom, of: iconImageView, withOffset: 16)
                titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 12)
                titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 12)
                titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 31)
                titleLabel.autoSetDimension(.width, toSize: 112)
            } else {
                titleLabel.font = UIFont.systemFont(ofSize: 14)
                titleLabel.numberOfLines = 0
                titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 21)
                titleLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 21)
                titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 20)
                titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 20)
                titleLabel.autoSetDimension(.width, toSize: 212, relation: .lessThanOrEqual)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(to view: UIView) {
        if let previous = Toast.global {
            previous.hide()
        }
        Toast.global = self
        
        view.addSubview(self)
        frame = view.bounds
        borderView.alpha = 0.0
        borderView.fadeIn() {
            if self.params.duration >= 0 {
                let duration = TimeInterval(self.params.duration / 1000)
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.hide()
                    if Toast.global === self {
                        Toast.global = nil
                    }
                }
            }
        }
    }
    
    func hide() {
        borderView.fadeOut() {
            self.removeFromSuperview()
        }
    }

}
