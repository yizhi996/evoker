//
//  LocationSettingViewModel.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class LocationSettingViewModel {
    
    let tableViewInfo = StaticTableViewInfo()
    let sectionInfo: StaticTableViewSectionInfo
    
    var selectedKey: String
    
    var popViewControllerHandler: ((String) -> Void)?
    
    init(current: String) {
        selectedKey = current
        
        sectionInfo = StaticTableViewSectionInfo(header: "你的位置信息将用于小程序位置接口的效果展示")
        
        let info = [["key": "deny", "title": "不允许"],
                    ["key": "front", "title": "不仅在使用小程序期间"],
                    ["key": "back", "title": "使用小程序期间和离开小程序后"]]
        info.forEach { data in
            let title = data["title"]!
            let key = data["key"]!
            let cellInfo = StaticTableViewCellInfo()
                .titleColor(UIColor.color("#000".hexColor(alpha: 0.9), dark: "#fff".hexColor(alpha: 0.9)))
                .height(56)
                .title(title)
                .selectionStyle(.default)
                .didSelect { [unowned self] _ in
                    self.selectedKey = key
                    self.sectionInfo.cells.forEach { cellInfo in
                        let key = cellInfo.userInfo["key"] as! String
                        cellInfo.accessoryView?.isHidden = key != selectedKey
                    }
                }
            cellInfo.userInfo["key"] = key
            let checkedImage = UIImageView(image: UIImage(builtIn: "hud-success-icon")?.withRenderingMode(.alwaysTemplate))
            checkedImage.tintColor = "#1989fa".hexColor()
            checkedImage.isHidden = key != selectedKey
            checkedImage.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            cellInfo.accessoryView(checkedImage)
            sectionInfo.append(cellInfo)
        }
        
        tableViewInfo.append(sectionInfo)
    }

}

extension LocationSettingViewModel {
    
    func generateViewController() -> UIViewController {
        return LocationSettingViewController(viewModel: self)
    }
}

