//
//  CoverView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class CoverView: UIButton, TransitionView {
    
    var clickHandler: EmptyBlock?
    
    let contentView: TransitionView
    
    init(contentView: TransitionView) {
        self.contentView = contentView
        super.init(frame: .zero)

        alpha = 0
        
        backgroundColor = "#000000".hexColor(alpha: 0.5)
        
        addTarget(self, action: #selector(onClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClick() {
        clickHandler?()
    }
    
    func show(to view: UIView) {
        view.addSubview(self)
        frame = view.frame
        alpha = 0.0
        fadeIn()
        contentView.show(to: self)
    }
    
    func hide() {
        contentView.hide()
        fadeOut() {
            self.removeFromSuperview()
        }
    }
}
