//
//  TextInputCompleteView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class TextInputCompleteView: UIView {
    
    var onClick: EmptyBlock?
    
    let completeButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let line = UIView()
        line.backgroundColor = "#000000".hexColor(alpha: 0.1)
        addSubview(line)
        line.autoPinEdge(toSuperviewEdge: .top)
        line.autoPinEdge(toSuperviewEdge: .left)
        line.autoPinEdge(toSuperviewEdge: .right)
        line.autoSetDimension(.height, toSize: 1)
        
        completeButton.setTitle("完成", for: .normal)
        completeButton.setTitleColor("#1989fa".hexColor(), for: .normal)
        completeButton.setTitleColor("#1989fa".hexColor(alpha: 0.5), for: .highlighted)
        completeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        completeButton.addTarget(self, action: #selector(_onClick), for: .touchUpInside)
        addSubview(completeButton)
        
        completeButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        completeButton.autoPinEdge(toSuperviewEdge: .right, withInset: 15)
        
        self.frame.size.height = 54
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func _onClick() {
        onClick?()
    }
}
