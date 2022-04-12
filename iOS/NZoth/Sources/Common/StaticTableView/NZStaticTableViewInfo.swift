//
//  NZStaticTableViewInfo.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol NZStaticTableViewListProtocol: AnyObject {
    
    associatedtype T
    
    var count: Int { get }
    
    func append(_ info: T)
    
    func remove(at index: Int)
}

class NZStaticTableViewInfo: NSObject {
    
    private(set) var sections: [NZStaticTableViewSectionInfo] = []
    
    var accessoryButtonTappedHandler: ((NZStaticTableViewCellInfo, IndexPath) -> Void)?
    
    var commitEditingHandler: ((NZStaticTableViewCellInfo, IndexPath) -> Void)?
    
    let tableView: UITableView
    
    init(frame: CGRect, style: UITableView.Style) {
        tableView = UITableView(frame: frame, style: style)
        super.init()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    convenience init(style: UITableView.Style) {
        self.init(frame: .zero, style: style)
    }
    
    convenience override init() {
        self.init(frame: .zero, style: .grouped)
    }
}

extension NZStaticTableViewInfo: NZStaticTableViewListProtocol {
    
    typealias T = NZStaticTableViewSectionInfo
    
    var count: Int {
        return sections.count
    }
    
    func append(_ info: T) {
        sections.append(info)
    }
    
    func remove(at index: Int) {
        guard index < count else { return }
        sections.remove(at: index)
        tableView.deleteSections(IndexSet(integer: index), with: .fade)
    }
    
}

extension NZStaticTableViewInfo {
    
    func removeAll() {
        sections.removeAll()
        tableView.reloadData()
    }
    
    func remove(indexPath: IndexPath) {
        let info = sections[indexPath.section]
        info.remove(at: indexPath.row)
        if info.count > 0 {
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else {
            remove(at: indexPath.section)
        }
    }
    
    func fetchInfo(at indexPath: IndexPath) -> NZStaticTableViewCellInfo {
        return sections[indexPath.section].cells[indexPath.row]
    }
}

extension NZStaticTableViewInfo: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = fetchInfo(at: indexPath)
        
        let cellStyle = cellInfo.cellStyle
        let identifier = "NZStaticTableView_\(cellStyle.rawValue)_\(cellInfo.height)"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if let cell = cell {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            cell.textLabel?.text = ""
        } else {
            cell = UITableViewCell(style: cellStyle, reuseIdentifier: identifier)
        }
        cellInfo.make(cell: cell!)
        cellInfo.cell = cell
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = sections[section]
        return sectionInfo.header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let sectionInfo = sections[section]
        return sectionInfo.footer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionInfo = sections[section]
        if let handler = sectionInfo.makeHeaderViewHandler {
            return handler(sectionInfo)
        } else if let title = self.tableView(tableView, titleForHeaderInSection: section) {
            return createSectionTitleView(title)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionInfo = sections[section]
        if let handler = sectionInfo.makeFooterViewHandler {
            return handler(sectionInfo)
        } else if let title = self.tableView(tableView, titleForFooterInSection: section) {
            return createSectionTitleView(title)
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionInfo = sections[section]
        if self.tableView(tableView, titleForHeaderInSection: section) != nil {
            return 42
        } else {
            return sectionInfo.headerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let sectionInfo = sections[section]
        if self.tableView(tableView, titleForFooterInSection: section) != nil {
            return 42
        } else {
            return sectionInfo.footerHeight
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellInfo = fetchInfo(at: indexPath)
        return cellInfo.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = fetchInfo(at: indexPath)
        cellInfo.didSelectHandler?(cellInfo)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cellInfo = fetchInfo(at: indexPath)
        accessoryButtonTappedHandler?(cellInfo, indexPath)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cellInfo = fetchInfo(at: indexPath)
        return cellInfo.editStyle != .none
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let cellInfo = fetchInfo(at: indexPath)
        commitEditingHandler?(cellInfo, indexPath)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        let cellInfo = fetchInfo(at: indexPath)
        return cellInfo.editStyle
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        let cellInfo = fetchInfo(at: indexPath)
        return cellInfo.editStyle != .none
    }
    
}

extension NZStaticTableViewInfo {
    
    func createSectionTitleView(_ title: String) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.text = title
        label.textColor = "#888888".hexColor()
        label.numberOfLines = 1
        view.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .left, withInset: 16)
        label.autoPinEdge(toSuperviewEdge: .right, withInset: 16)
        label.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        return view
    }
}

