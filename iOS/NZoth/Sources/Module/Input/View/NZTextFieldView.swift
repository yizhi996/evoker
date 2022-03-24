//
//  NZTextFieldView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTextFieldView: UIView, NZInput {
    
    public var onFocus: NZEmptyBlock?
    
    public var onBlur: NZEmptyBlock?
    
    public var textChanged: NZStringBlock?
    
    public var onKeyboardReturn: NZEmptyBlock?
    
    public var inputId = 0
    
    public var maxLength = -1
    
    public var adjustPosition = true
    
    public var needFocus = false
    
    public var field: UIResponder {
        return textField
    }
    
    let textField = UITextField()
        
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        addSubview(textField)
        
        textField.autoPinEdgesToSuperviewEdges()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setText(_ text: String) {
        textField.text = text
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if textField.markedTextRange != nil {
            return
        }
        if maxLength > -1, let count = textField.text?.count, count > maxLength {
            textField.text = textField.text?.substring(range: NSRange(location: 0, length: maxLength))
        }
        textChanged?(textField.text ?? "")
    }
}

extension  NZTextFieldView: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onKeyboardReturn?()
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        onFocus?()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        onBlur?()
    }
    
}

