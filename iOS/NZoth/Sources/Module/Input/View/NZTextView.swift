//
//  NZTextView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

open class NZTextView: UIView, NZInput {
 
    public var onFocus: NZEmptyBlock?
    
    public var onBlur: NZEmptyBlock?
    
    public var textChanged: NZStringBlock?
    
    public var onKeyboardReturn: NZEmptyBlock?
    
    public var textHeightChange: ((CGFloat, Int) -> Void)?
    
    public var inputId = 0
    
    public var maxLength = -1
    
    public var adjustPosition = true
    
    public var needFocus: Bool = false
    
    public var input: UIResponder {
        return textView
    }
    
    public var isAutoHeight = true
    
    private var prevHeight: CGFloat = 0
    
    
    let textView = UITextView()
    let placeholderLabel = UILabel()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 16.0)
        textView.textColor = .black
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.showsHorizontalScrollIndicator = false

        addSubview(textView)
        
        textView.autoPinEdgesToSuperviewEdges()
        
        placeholderLabel.font = UIFont.systemFont(ofSize: 16.0)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = .black
        addSubview(placeholderLabel)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setText(_ text: String) {
        textView.text = text
    }

}

extension NZTextView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        if maxLength > -1, let count = textView.text?.count, count > maxLength {
            textView.text = textView.text?.substring(range: NSRange(location: 0, length: maxLength))
        }
        
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
        
        let maxWidth = textView.frame.width - textView.textContainer.lineFragmentPadding * 2
        var height = textView.attributedText.boundingRect(with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                                                          options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                          context: nil).height
        height += textView.textContainerInset.top + textView.textContainerInset.bottom
        height = ceil(height)
        
        NotificationCenter.default.post(name: NZTextView.didChangeHeightNotification, object: self)
        
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
        if  text == "\n" {
            onKeyboardReturn?()
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension NZTextView {
    
    public static let heightChangeSubscribeKey = NZSubscribeKey("WEBVIEW_TEXTAREA_HEIGHT_CHANGE")
    
}

extension NZTextView {
    
    public static let didChangeHeightNotification = Notification.Name("didChangeHeightNotification")
}
