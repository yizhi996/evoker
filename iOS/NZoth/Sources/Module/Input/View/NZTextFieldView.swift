//
//  NZTextFieldView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTextFieldView: UIView, NZTextInput {
    
    public var onFocus: NZEmptyBlock?
    
    public var onBlur: NZEmptyBlock?
    
    public var textChanged: NZStringBlock?
    
    public var onKeyboardReturn: NZEmptyBlock?
    
    public var inputId = 0
    
    public var maxLength = -1
    
    public var adjustPosition = true
    
    public var cursor = -1
    
    public var selectionStart = -1
    
    public var selectionEnd = -1
    
    public var confirmHold = false
    
    public var cursorSpacing: CGFloat = 0
    
    public var holdKeyboard = false {
        didSet {
            textField.holdKeyboard = holdKeyboard
        }
    }
    
    public var needFocus = false
    
    public var field: UITextInput {
        return textField
    }
    
    let textField = _NZTextFieldView()
    
    open override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }
    
    enum ConfirmType: String, Decodable {
        case send
        case search
        case next
        case go
        case done
        
        func toNatively() -> UIReturnKeyType {
            switch self {
            case .send:
                return .send
            case .search:
                return .search
            case .next:
                return .next
            case .go:
                return .go
            case .done:
                return .done
            }
        }
    }
    
    enum KeyboardType: String, Decodable {
        case text
        case number
        case digit
        
        func toNatively() -> UIKeyboardType {
            switch self {
            case .text:
                return .default
            case .number:
                return .numberPad
            case .digit:
                return .decimalPad
            }
        }
    }
        
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
    
    public func startEdit() {
        textField.becomeFirstResponder()
    }
    
    public func endEdit() {
        textField.forceHideKeyboard = true
        textField.resignFirstResponder()
        textField.forceHideKeyboard = false
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if textField.markedTextRange != nil {
            return
        }
        if maxLength > 0, let count = textField.text?.count, count > maxLength {
            textField.text = textField.text?.substring(range: NSRange(location: 0, length: maxLength))
        }
        textChanged?(textField.text ?? "")
    }
}

extension  NZTextFieldView: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onKeyboardReturn?()
        if !confirmHold {
            endEdit()
        }
        return true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if needFocus {
            if selectionStart > -1 && selectionEnd > -1 {
                if let startPosition = textField.position(from: textField.beginningOfDocument, offset: selectionStart),
                   let endPosition = textField.position(from: textField.beginningOfDocument, offset: selectionEnd) {
                    textField.selectedTextRange = textField.textRange(from: startPosition, to: endPosition)
                }
            } else if cursor > -1 {
                if let position = textField.position(from: textField.beginningOfDocument, offset: cursor) {
                    textField.selectedTextRange = textField.textRange(from: position, to: position)
                }
            }
        }
        onFocus?()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        onBlur?()
    }
    
}

final class _NZTextFieldView: UITextField {
    
    var holdKeyboard = false
    
    var forceHideKeyboard = false
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        if forceHideKeyboard {
            return super.resignFirstResponder()
        }
        if holdKeyboard {
            return false
        }
        delegate?.textFieldDidEndEditing?(self)
        selectedTextRange = nil
        return true
    }
}
