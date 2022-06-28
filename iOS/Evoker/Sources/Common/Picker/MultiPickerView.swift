//
//  MultiPickerView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class MultiPickerView: UIView {
    
    struct PickData: Decodable {
        let columns: [[String]]
        let title: String?
        let current: [Int]
    }
    
    var columnChangeHandler: ((Int, Int) -> Void)?
    
    let picker = UIPickerView()
    
    var data: PickData {
        didSet {
            for i in 0..<data.columns.count {
                let row = data.current[i]
                picker.selectRow(row, inComponent: i, animated: false)
            }
            currentIndex = data.current
            picker.reloadAllComponents()
        }
    }
    
    var currentIndex: [Int] = []
    
    init(data: PickData) {
        self.data = data
        super.init(frame: .zero)
        
        picker.delegate = self
        picker.dataSource = self
        
        for i in 0..<data.columns.count {
            let row = data.current[i]
            picker.selectRow(row, inComponent: i, animated: false)
        }
      
        currentIndex = data.current
        
        addSubview(picker)
        picker.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MultiPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return data.columns.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.columns[component].count
    }
    
}

extension MultiPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data.columns[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex[component] = row
        columnChangeHandler?(component, row)
    }
    
}

extension MultiPickerView {
    
    static let onChangeColumnSubscribeKey = SubscribeKey(rawValue: "WEBVIEW_MULTI_PICKER_COLUMN_CHANGE")
}
