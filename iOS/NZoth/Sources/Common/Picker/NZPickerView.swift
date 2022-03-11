//
//  NZPickerView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZPickerView: UIView {
    
    struct PickData: Decodable {
        let columns: Columns
        let dataType: DataType
        var title: String?
        
        enum CodingKeys: String, CodingKey {
            case columns, dataType, title
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            columns = try container.decode(Columns.self, forKey: .columns)
            dataType = try container.decode(DataType.self, forKey: .dataType)
            if container.contains(.title) {
                title = try container.decode(String.self, forKey: .title)
            }
        }
    }
    
    enum DataType: String, Decodable {
        case plain
        case cascade
        case object
    }
    
    enum Columns: Decodable {
        case cascade([Cascade])
        case object([ObjectColumn])
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode([Cascade].self) {
                self = .cascade(x)
            } else if let x = try? container.decode([ObjectColumn].self) {
                self = .object(x)
            } else {
                throw DecodingError.typeMismatch(Columns.self,
                                                 DecodingError.Context(codingPath: decoder.codingPath,
                                                                                     debugDescription: "Wrong type for Columns"))
            }
        }
    }
    
    struct Cascade: Decodable {
        let values: [CascadeColumn]
    }
    
    struct CascadeColumn: Decodable {
        let text: String
        let children: [CascadeColumn]?
        
        var nestingDepth: Int {
            return 1 + (children?.first?.nestingDepth ?? 0)
        }
    }
    
    struct ObjectColumn: Decodable {
        let values: [String]
        let defaultIndex: Int?
    }
    
    let picker = UIPickerView()
    
    let data: PickData
    
    var numberOfComponents = 0
    var rows: [[CascadeColumn]] = []
    
    init(data: PickData) {
        self.data = data
        super.init(frame: .zero)
        
        picker.delegate = self
        picker.dataSource = self
        
        switch data.columns {
        case .object(let x):
            numberOfComponents = x.count
            
            for i in 0..<numberOfComponents {
                let row = x[i].defaultIndex ?? 0
                picker.selectRow(row, inComponent: i, animated: false)
            }
            
        case .cascade(let x):
            numberOfComponents = x.first?.values.first?.nestingDepth ?? 1
            if let values = x.first?.values {
                var col = values
                rows.insert(col, at: 0)
                for i in 1..<numberOfComponents {
                    col = col.first?.children ?? []
                    rows.insert(col, at: i)
                }
            }
        }

        addSubview(picker)
        picker.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func result() -> [String: Any] {
        switch data.columns {
        case .object(let x):
            if x.count == 1 {
                let row = picker.selectedRow(inComponent: 0)
                let value = x[0].values[row]
                return ["index": row, "value": value]
            } else if x.count > 1 {
                var indexs: [Int] = []
                var values: [String] = []
                for i in 0..<numberOfComponents {
                    let row = picker.selectedRow(inComponent: i)
                    let value = x[i].values[row]
                    indexs.append(row)
                    values.append(value)
                }
                return ["indexs": indexs, "values": values]
            }
            return [:]
        case .cascade:
            var indexs: [Int] = []
            var values: [String] = []
            for i in 0..<numberOfComponents {
                let row = picker.selectedRow(inComponent: i)
                let value = rows[i][row]
                indexs.append(row)
                values.append(value.text)
            }
            return ["indexs": indexs, "values": values]
        }
    }
}

extension NZPickerView: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch data.columns {
        case .object(let x):
            return x[component].values.count
        case .cascade:
            return rows[component].count
        }
    }
    
}

extension NZPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch data.columns {
        case .object(let x):
            return x[component].values[row]
        case .cascade:
            return rows[component][row].text
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch data.columns {
        case .object:
            break
        case .cascade:
            if component < numberOfComponents - 1 {
                var values = rows[component]
                if !values.isEmpty {
                    values = values[row].children ?? []
                }
                rows[component + 1] = values
                
                self.pickerView(pickerView, didSelectRow: 0, inComponent: component + 1)
                pickerView.selectRow(0, inComponent: component + 1, animated: false)
            }
            pickerView.reloadComponent(component)
        }
    }
    
}
