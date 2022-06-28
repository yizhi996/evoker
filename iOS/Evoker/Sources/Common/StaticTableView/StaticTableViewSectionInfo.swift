//
//  StaticTableViewSectionInfo.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class StaticTableViewSectionInfo {
    
    private(set) var cells: [StaticTableViewCellInfo] = []
    
    var header: String?
    
    var footer: String?
    
    var headerHeight: CGFloat = 0
    
    var footerHeight: CGFloat = 0
    
    var makeHeaderViewHandler: ((StaticTableViewSectionInfo) -> UIView)?
    
    var makeFooterViewHandler: ((StaticTableViewSectionInfo) -> UIView)?
    
    convenience init(header: String) {
        self.init()
        self.header = header
    }
    
    convenience init(footer: String) {
        self.init()
        self.footer = footer
    }
    
    convenience init(header: String, footer: String) {
        self.init()
        self.header = header
        self.footer = footer
    }
    
}

extension StaticTableViewSectionInfo: StaticTableViewListProtocol {
    
    typealias T = StaticTableViewCellInfo
    
    var count: Int {
        return cells.count
    }
    
    func append(_ info: T) {
        cells.append(info)
    }
    
    func remove(at index: Int) {
        guard index < cells.count else { return }
        cells.remove(at: index)
    }
    
    func removeAll() {
        cells = []
    }
}
