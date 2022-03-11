//
//  NZCoverView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZCoverView: UIButton {
    
    var clickHandler: NZEmptyBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
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
    }
    
    func hide() {
        fadeOut() {
            self.removeFromSuperview()
        }
    }
}
