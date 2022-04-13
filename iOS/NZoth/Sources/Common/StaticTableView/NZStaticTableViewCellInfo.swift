//
//  NZStaticTableViewCellInfo.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZStaticTableViewCellInfo {
    
    weak var cell: UITableViewCell? = nil
    
    var title = ""
    
    var titleColor = UIColor.black
    
    var titleFont = UIFont.systemFont(ofSize: 17)
    
    var leftValue = ""
    
    var leftValueColor = UIColor.black
    
    var leftValueFont = UIFont.systemFont(ofSize: 17)
    
    var rightValue = ""
    
    var rightValueColor = UIColor.black
    
    var rightValueFont = UIFont.systemFont(ofSize: 17)
    
    var image: UIImage?
    
    var accessoryView: UIView?
    
    var accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator
    
    var height: CGFloat = 44
    
    var cellStyle: UITableViewCell.CellStyle = .value1
    
    var selectionStyle: UITableViewCell.SelectionStyle = .default
    
    var editStyle: UITableViewCell.EditingStyle = .none
    
    lazy var userInfo: [String: Any] = [:]
    
    var didSelectHandler: ((NZStaticTableViewCellInfo) -> Void)?
    
}

extension NZStaticTableViewCellInfo {
    
    @discardableResult
    func title(_ value: String) -> Self {
        title = value
        return self
    }
    
    @discardableResult
    func titleColor(_ value: UIColor) -> Self {
        titleColor = value
        return self
    }
    
    @discardableResult
    func titleFont(_ value: UIFont) -> Self {
        titleFont = value
        return self
    }
    
    @discardableResult
    func leftValue(_ value: String) -> Self {
        leftValue = value
        return self
    }
    
    @discardableResult
    func leftValueColor(_ value: UIColor) -> Self {
        leftValueColor = value
        return self
    }
    
    @discardableResult
    func leftValueFont(_ value: UIFont) -> Self {
        leftValueFont = value
        return self
    }
    
    @discardableResult
    func rightValue(_ value: String) -> Self {
        rightValue = value
        return self
    }
    
    @discardableResult
    func rightValueColor(_ value: UIColor) -> Self {
        rightValueColor = value
        return self
    }
    
    @discardableResult
    func rightValueFont(_ value: UIFont) -> Self {
        rightValueFont = value
        return self
    }
    
    @discardableResult
    func image(_ value: UIImage) -> Self {
        image = value
        return self
    }
    
    @discardableResult
    func accessoryView(_ value: UIView) -> Self {
        accessoryView = value
        return self
    }
    
    @discardableResult
    func accessoryType(_ value: UITableViewCell.AccessoryType) -> Self {
        accessoryType = value
        return self
    }
    
    @discardableResult
    func height(_ value: CGFloat) -> Self {
        height = value
        return self
    }
    
    @discardableResult
    func cellStyle(_ value: UITableViewCell.CellStyle) -> Self {
        cellStyle = value
        return self
    }
    
    @discardableResult
    func selectionStyle(_ value: UITableViewCell.SelectionStyle) -> Self {
        selectionStyle = value
        return self
    }
    
    @discardableResult
    func editStyle(_ value: UITableViewCell.EditingStyle) -> Self {
        editStyle = value
        return self
    }
    
    @discardableResult
    func didSelect(_ handler: @escaping (NZStaticTableViewCellInfo) -> Void) -> Self {
        didSelectHandler = handler
        return self
    }

}

extension NZStaticTableViewCellInfo {
    
    @objc
    func make(cell: UITableViewCell) {
        cell.selectionStyle = selectionStyle
        
        cell.accessoryType = accessoryType
        
        var imageView: UIImageView? = nil
        if let image = image {
            imageView = UIImageView(image: image)
            cell.contentView.addSubview(imageView!)
        }
        
        var titleLabel: UILabel? = nil
        if !title.isEmpty {
            titleLabel = UILabel()
            titleLabel!.text = title
            titleLabel!.font = titleFont
            titleLabel!.textColor = titleColor
            titleLabel!.textAlignment = .left
            titleLabel!.lineBreakMode = .byTruncatingTail
            cell.contentView.addSubview(titleLabel!)
        }
        
        var leftValueLabel: UILabel? = nil
        if !leftValue.isEmpty {
            leftValueLabel = UILabel()
            leftValueLabel!.text = leftValue
            leftValueLabel!.textColor = leftValueColor
            leftValueLabel!.font = leftValueFont
            cell.contentView.addSubview(leftValueLabel!)
        }
        
        var rightValueLabel: UILabel? = nil
        if !rightValue.isEmpty {
            rightValueLabel = UILabel()
            rightValueLabel!.text = rightValue
            rightValueLabel!.textColor = rightValueColor
            rightValueLabel!.font = rightValueFont
            cell.contentView.addSubview(rightValueLabel!)
        }
        
        if let accessoryView = accessoryView {
            cell.accessoryView = accessoryView
        }
        
        imageView?.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
        imageView?.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        titleLabel?.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        leftValueLabel?.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        rightValueLabel?.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        if let imageView = imageView {
            titleLabel?.autoPinEdge(.left, to: .right, of: imageView, withOffset: 15.0)
        } else {
            titleLabel?.autoPinEdge(toSuperviewEdge: .left, withInset: 15.0)
        }
        
        if let titleLabel = titleLabel {
            leftValueLabel?.autoPinEdge(.left, to: .right, of: titleLabel, withOffset: 15.0)
        } else {
            leftValueLabel?.autoPinEdge(toSuperviewEdge: .left)
        }
        
        if cell.accessoryType != .none {
            rightValueLabel?.autoPinEdge(toSuperviewEdge: .right, withInset: 5.0)
        } else {
            rightValueLabel?.autoPinEdge(toSuperviewEdge: .right, withInset: 15.0)
        }
    }
}
