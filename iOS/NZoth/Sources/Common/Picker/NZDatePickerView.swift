//
//  NZDatePickerView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZDatePickerView: UIView {
    
    struct Data: Decodable {
        let title: String?
        let start: String?
        let end: String?
        let value: String?
        let mode: String
    }
    
    let picker = UIDatePicker()
    let fmt = DateFormatter()
    
    init(data: Data) {
        super.init(frame: .zero)
        
        if data.mode == "time" {
            picker.datePickerMode = .time
            fmt.dateFormat = "hh:mm"
        } else {
            picker.datePickerMode = .date
            fmt.dateFormat = "yyyy-MM-dd"
        }
        
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        
        if let start = data.start {
            picker.minimumDate = fmt.date(from: start)
        }
        
        if let end = data.end {
            picker.maximumDate = fmt.date(from: end)
        }
        
        if let value = data.value, !value.isEmpty, let defaultDate = fmt.date(from: value)  {
            picker.date = defaultDate
        }
    
        addSubview(picker)
        picker.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
