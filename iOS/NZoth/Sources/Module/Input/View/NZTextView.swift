//
//  NZTextView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTextView: UIView, NZTextInput {
        
    public var onFocus: NZEmptyBlock?
    
    public var onBlur: NZEmptyBlock?
    
    public var textChanged: NZStringBlock?
    
    public var onKeyboardReturn: NZEmptyBlock?
    
    public var textHeightChange: ((CGFloat, Int) -> Void)?
    
    public var inputId = 0
    
    public var maxLength = -1
    
    public var adjustPosition = true
    
    public var cursor = -1
    
    public var selectionStart = -1
    
    public var selectionEnd = -1
    
    public var confirmHold = false
    
    public var cursorSpacing: CGFloat = 0
    
    public var holdKeyboard = false
    
    public var needFocus = false
    
    public var showConfirmBar = true
    
    public var field: UITextInput {
        return textView
    }
    
    public var isAutoHeight = true
    
    private var prevHeight: CGFloat = 0
    
    let textView = _NZTextView()
    
    let placeholderLabel = UILabel()
    
    open override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
    
    enum ConfirmType: String, Decodable {
        case send
        case search
        case next
        case go
        case done
        case `return`
        
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
            case .return:
                return .default
            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        placeholderLabel.font = UIFont.systemFont(ofSize: 16.0)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .black
        addSubview(placeholderLabel)
        
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.showsHorizontalScrollIndicator = false

        addSubview(textView)
        
        textView.autoPinEdgesToSuperviewEdges()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setText(_ text: String) {
        textView.text = text
    }
    
    public func startEdit() {
        textView.becomeFirstResponder()
    }
    
    public func endEdit() {
        textView.forceHideKeyboard = true
        textView.resignFirstResponder()
        textView.forceHideKeyboard = false
    }
}

extension NZTextView: UITextViewDelegate {
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if needFocus {
            if selectionStart > -1 && selectionEnd > -1 {
                if let startPosition = textView.position(from: textView.beginningOfDocument, offset: selectionStart),
                   let endPosition = textView.position(from: textView.beginningOfDocument, offset: selectionEnd) {
                    textView.selectedTextRange = textView.textRange(from: startPosition, to: endPosition)
                }
            } else if cursor > -1 {
                if let position = textView.position(from: textView.beginningOfDocument, offset: cursor) {
                    textView.selectedTextRange = textView.textRange(from: position, to: position)
                }
            }
        }
        onFocus?()
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        onBlur?()
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if maxLength > 0, let count = textView.text?.count, count > maxLength {
            textView.text = textView.text?.substring(range: NSRange(location: 0, length: maxLength))
        }
        
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        
        NotificationCenter.default.post(name: NZTextView.didChangeHeightNotification, object: self)
        
        let height = textView.contentSize.height
        if height != prevHeight {
            prevHeight = height
            if isAutoHeight {
                let lineCount = Int(floor(height / textView.font!.lineHeight))
                textHeightChange?(height, lineCount)
            }
        }
        
        if textView.markedTextRange != nil {
            return
        }

        textChanged?(text)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.returnKeyType == .default {
            return true
        } else if  text == "\n" {
            onKeyboardReturn?()
            if !confirmHold {
                endEdit()
            }
            return false
        }
        return true
    }
    
    func getContentHeight() -> CGFloat {
        let maxWidth = frame.width - textView.textContainer.lineFragmentPadding * 2 - textView.textContainerInset.left - textView.textContainerInset.right
        var height = textView.attributedText.calcHeight(width: maxWidth)
        height = max(height, textView.font!.lineHeight)
        height += textView.textContainerInset.top + textView.textContainerInset.bottom
        return ceil(height)
    }
}

extension NZTextView {
    
    public static let heightChangeSubscribeKey = NZSubscribeKey("WEBVIEW_TEXTAREA_HEIGHT_CHANGE")
    
}

extension NZTextView {
    
    public static let didChangeHeightNotification = Notification.Name("didChangeHeightNotification")
}

final class _NZTextView: UITextView {
    
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
        delegate?.textViewDidEndEditing?(self)
        selectedTextRange = nil
        return true
    }
}
