//
//  PickerView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class PickerView: UIView {
    
    struct PickData: Decodable {
        let columns: [String]
        let title: String?
        let current: Int
    }
    
    let picker = UIPickerView()
    
    let data: PickData
    
    var currentIndex = 0
    
    init(data: PickData) {
        self.data = data
        super.init(frame: .zero)
        
        picker.delegate = self
        picker.dataSource = self
        
        picker.selectRow(data.current, inComponent: 0, animated: false)
        currentIndex = data.current
        
        addSubview(picker)
        picker.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.columns.count
    }
    
}

extension PickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return data.columns[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
    }
    
}
