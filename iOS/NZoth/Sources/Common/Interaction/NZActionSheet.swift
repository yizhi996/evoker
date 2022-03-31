//
//  NZActionSheet.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZActionSheet: UIView {
    
    struct Params: Decodable {
        let alertText: String?
        let itemList: [String]
        let itemColor: String?
    }
    
    let params: Params
    
    let tableView = UITableView()
    let cancelButton = UIButton()
    
    var confirmHandler: NZIntBlock?
    var cancelHandler: NZEmptyBlock?
    
    var hasAlertText: Bool {
        if let alertText = params.alertText, !alertText.isEmpty {
           return true
        }
        return false
    }
    
    init(params: Params) {
        self.params = params
        super.init(frame: .zero)
        
        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.isScrollEnabled = false
        tableView.bounces = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .nzWhite
        tableView.register(NZActionSheetCell.self)
        addSubview(tableView)
        tableView.autoPinEdge(toSuperviewEdge: .top)
        tableView.autoPinEdge(toSuperviewEdge: .left)
        tableView.autoPinEdge(toSuperviewEdge: .right)
        tableView.autoSetDimension(.height, toSize: 56 * CGFloat(params.itemList.count) + (hasAlertText ? 56 : 0))
        
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.color("#f7f7f7".hexColor(), dark: "#1c1c1e".hexColor())
        addSubview(spaceView)
        spaceView.autoPinEdge(.top, to: .bottom, of: tableView)
        spaceView.autoPinEdge(toSuperviewEdge: .left)
        spaceView.autoPinEdge(toSuperviewEdge: .right)
        spaceView.autoSetDimension(.height, toSize: 8)
        
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.backgroundColor = UIColor.color(.white, dark: "#2c2c2e".hexColor())
        cancelButton.setTitleColor(.nzTextBlack, for: .normal)
        cancelButton.setBackgroundImage(UIImage.color(UIColor.color("#000000".hexColor(alpha: 0.1), dark: "#8e8e93".hexColor())), for: .highlighted)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        cancelButton.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                    left: 0,
                                                    bottom: Constant.safeAreaInsets.bottom,
                                                    right: 0)
        cancelButton.addTarget(self, action: #selector(onClickCancel), for: .touchUpInside)
        addSubview(cancelButton)
        cancelButton.autoSetDimension(.height, toSize: 56 + Constant.safeAreaInsets.bottom)
        cancelButton.autoPinEdge(.top, to: .bottom, of: spaceView)
        cancelButton.autoPinEdge(toSuperviewEdge: .left)
        cancelButton.autoPinEdge(toSuperviewEdge: .right)
        cancelButton.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                let color = UIColor.color("#000000".hexColor(alpha: 0.1), dark: "#8e8e93".hexColor())
                let image = UIImage.color(color)
                cancelButton.setBackgroundImage(image, for: .highlighted)
            }
        }
    }
    
    @objc func onClickCancel() {
        cancelHandler?()
    }
    
    func show(to view: UIView) {
        view.addSubview(self)
        autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        popup()
    }
    
    func hide() {
        popdown() {
            self.removeFromSuperview()
        }
    }
}

extension NZActionSheet: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return params.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: NZActionSheetCell = tableView.dequeueReusableCell(for: indexPath)
        let item = params.itemList[indexPath.row]
        cell.titleLabel.text = item
        if let itemColor = params.itemColor {
            cell.titleLabel.textColor = itemColor.hexColor()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if hasAlertText {
            let headerView = UIView()
            headerView.backgroundColor = .nzWhite
            let textLabel = UILabel()
            textLabel.numberOfLines = 0
            textLabel.text = params.alertText
            textLabel.font = UIFont.systemFont(ofSize: 14.0)
            textLabel.textColor = .systemGray
            headerView.addSubview(textLabel)
            textLabel.autoCenterInSuperview()
            
            let spaceView = UIView()
            spaceView.backgroundColor = UIColor.color("#f7f7f7".hexColor(), dark: "#1c1c1e".hexColor())
            headerView.addSubview(spaceView)
            spaceView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
            spaceView.autoSetDimension(.height, toSize: 1)

            return headerView
        }
        return nil
    }
    
}

extension NZActionSheet: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return hasAlertText ? 56 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        confirmHandler?(indexPath.row)
    }
    
}

class NZActionSheetCell: UITableViewCell, ReuseableCell {
    
    let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.color(.white, dark: "#2c2c2e".hexColor())
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.color("#000000".hexColor(alpha: 0.1), dark: "#8e8e93".hexColor())
        selectedBackgroundView = selectedView
        
        separatorInset = .zero

        titleLabel.font = UIFont.systemFont(ofSize: 17.0)
        titleLabel.textColor = .nzTextBlack
        contentView.addSubview(titleLabel)
        
        titleLabel.autoCenterInSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
