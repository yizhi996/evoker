//
//  NZTabBarView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTabBarView: UIView {
    
    public var isShow = false
    
    public var didSelectIndex: NZIntBlock?
    
    private var tabBarItems: [NZTabBarItem] =  []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let line = UIView()
        line.backgroundColor = UIColor(white: 0, alpha: 0.3)
        addSubview(line)
        line.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        line.autoSetDimension(.height, toSize: 1 / Constant.scale)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func load(config: NZAppConfig, envVersion: NZAppEnvVersion) {
        guard let tabBarInfo = config.tabBar else { return }
        
        tabBarItems.forEach { $0.removeFromSuperview() }
        tabBarItems = []
        
        var prev: NZTabBarItem?
        let y = 1 / Constant.scale
        let height = 48 - y
        for (index, item) in tabBarInfo.list.enumerated() {
            let tabBarItem = NZTabBarItem(type: .custom)
            tabBarItem.tag = index
            tabBarItem.setTitle(item.text, for: .normal)
            tabBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 10.0)
            tabBarItem.setTitleColor(tabBarInfo.color.hexColor(), for: .normal)
            tabBarItem.setTitleColor(tabBarInfo.selectedColor.hexColor(), for: .selected)
            if let iconPath = item.iconPath, !iconPath.isEmpty {
                let iconFile = FilePath.appStaticFilePath(appId: config.appId, envVersion: envVersion, src: iconPath)
                let image = UIImage(contentsOfFile: iconFile.path)
                tabBarItem.setImage(image, for: .normal)
            }
            if let iconPath = item.selectedIconPath, !iconPath.isEmpty {
                let iconFile = FilePath.appStaticFilePath(appId: config.appId, envVersion: envVersion, src: iconPath)
                let image = UIImage(contentsOfFile: iconFile.path)
                tabBarItem.setImage(image, for: .selected)
            }
            tabBarItem.addTarget(self, action: #selector(didSelectTab(_:)), for: .touchUpInside)
            
            addSubview(tabBarItem)
            tabBarItem.autoPinEdge(toSuperviewEdge: .top, withInset: y)
            tabBarItem.autoSetDimension(.height, toSize: height)
            if let prev = prev {
                tabBarItem.autoMatch(.width, to: .width, of: prev)
                tabBarItem.autoPinEdge(.left, to: .right, of: prev)
            } else {
                tabBarItem.autoPinEdge(toSuperviewEdge: .left)
            }
            if index == tabBarInfo.list.count - 1 {
                tabBarItem.autoPinEdge(toSuperviewEdge: .right)
            }
            prev = tabBarItem
            tabBarItems.append(tabBarItem)
        }
    }
    
    @objc open func didSelectTab(_ item: UIButton) {
        tabBarItems.forEach { $0.isSelected = false }
        item.isSelected = true
        didSelectIndex?(item.tag)
    }
    
    func setTabItemSelect(_ index: Int) {
        guard index < tabBarItems.count else { return }
        tabBarItems.forEach { $0.isSelected = false }
        tabBarItems[index].isSelected = true
    }
}
