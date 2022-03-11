//
//  MiniProgramNavigationBar.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class MiniProgramNavigationBar: UIView {
    
    let moreButton = UIButton(type: .custom)
    let closeButton = UIButton(type: .custom)
    
    let buttonWidth: CGFloat = 43.3
    let buttonHeight: CGFloat = 32
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let moreIcon = UIImage(builtIn: "mini-program-more-icon")
        moreButton.setImage(moreIcon, for: .normal)
        addSubview(moreButton)
        moreButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .right)
        moreButton.autoSetDimensions(to: CGSize(width: buttonWidth, height: buttonHeight))
        
        let closeIcon = UIImage(builtIn: "mini-program-close-icon")
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

}
