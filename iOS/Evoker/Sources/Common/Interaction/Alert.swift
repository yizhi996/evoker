//
//  Alert.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class Alert: UIView, TransitionView {
    
    struct Params: Decodable {
        let title: String?
        let content: String?
        let showCancel: Bool
        let cancelText: String
        let cancelColor: String
        let confirmText: String
        let confirmColor: String
        let editable: Bool
        let placeholderText: String?
    }
    
    let params: Params
    
    lazy var titleLabel = UILabel()
    let contentTextView = UITextView()
    lazy var placeholderLabel = UILabel()
    let confirmButton = UIButton()
    lazy var cancelButton = UIButton()
    
    var confirmHandler: StringBlock?
    var cancelHandler: EmptyBlock?
    
    init(params: Params) {
        self.params = params
        super.init(frame: .zero)
        
        alpha = 0
        
        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 8.0
        
        let hasTitle = params.title != nil
        if hasTitle {
            titleLabel.textColor = .black
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            titleLabel.textAlignment = .center
            titleLabel.text = params.title
            addSubview(titleLabel)
            titleLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
            titleLabel.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
            titleLabel.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        }
        
        if !params.editable {
            contentTextView.textColor = "#888888".hexColor()
            contentTextView.textAlignment = .center
            contentTextView.isEditable = false
            contentTextView.isScrollEnabled = false
            contentTextView.isSelectable = false
        } else {
            contentTextView.textColor = "#000000".hexColor()
            contentTextView.backgroundColor = UIColor.color("#f7f7f7".hexColor(), dark: "#1c1c1e".hexColor())
            contentTextView.becomeFirstResponder()
            
            placeholderLabel.font = UIFont.systemFont(ofSize: 17)
            placeholderLabel.numberOfLines = 1
            placeholderLabel.textColor = "#808080".hexColor()
            placeholderLabel.text = params.placeholderText
        }
        
        contentTextView.font = UIFont.systemFont(ofSize: 17)
        contentTextView.text = params.content
        addSubview(contentTextView)
        if hasTitle {
            contentTextView.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 16)
        } else {
            contentTextView.autoPinEdge(toSuperviewEdge: .top, withInset: 32)
        }
        contentTextView.autoPinEdge(toSuperviewEdge: .left, withInset: 25)
        contentTextView.autoPinEdge(toSuperviewEdge: .right, withInset: 25)
        if params.editable {
            contentTextView.delegate = self
            contentTextView.autoSetDimension(.height, toSize: 40)
            addSubview(placeholderLabel)
            placeholderLabel.autoPinEdge(.left, to: .left, of: contentTextView, withOffset: 4)
            placeholderLabel.autoPinEdge(.right, to: .right, of: contentTextView, withOffset: 4)
            placeholderLabel.autoPinEdge(.top, to: .top, of: contentTextView)
            placeholderLabel.autoPinEdge(.bottom, to: .bottom, of: contentTextView)
        }
        
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        confirmButton.setTitleColor(params.confirmColor.hexColor(), for: .normal)
        confirmButton.setTitle(params.confirmText, for: .normal)
        let highlightColor = UIImage.color("#000000".hexColor(alpha: 0.1))
        confirmButton.setBackgroundImage(highlightColor, for: .highlighted)
        confirmButton.addTarget(self, action: #selector(onClickConfirm), for: .touchUpInside)
        addSubview(confirmButton)
        confirmButton.autoSetDimension(.height, toSize: 56)
        confirmButton.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 16)
        if !params.showCancel {
            confirmButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        } else {
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            cancelButton.setTitleColor(params.cancelColor.hexColor(), for: .normal)
            cancelButton.setTitle(params.cancelText, for: .normal)
            cancelButton.setBackgroundImage(highlightColor, for: .highlighted)
            cancelButton.addTarget(self, action: #selector(onClickCancel), for: .touchUpInside)
            addSubview(cancelButton)
            cancelButton.autoSetDimension(.height, toSize: 56)
            cancelButton.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: 16)
            cancelButton.autoPinEdge(toSuperviewEdge: .left)
            cancelButton.autoPinEdge(toSuperviewEdge: .bottom)
            
            confirmButton.autoPinEdge(toSuperviewEdge: .right)
            confirmButton.autoPinEdge(toSuperviewEdge: .bottom)
            confirmButton.autoMatch(.width, to: .width, of: cancelButton)
            confirmButton.autoPinEdge(.left, to: .right, of: cancelButton)
        }
        
        let line = UIView()
        line.backgroundColor = "#000000".hexColor(alpha: 0.1)
        addSubview(line)
        line.autoPinEdge(.top, to: .top, of: confirmButton)
        line.autoPinEdge(toSuperviewEdge: .left)
        line.autoPinEdge(toSuperviewEdge: .right)
        line.autoSetDimension(.height, toSize: 1 / Constant.scale)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onClickConfirm() {
        confirmHandler?(contentTextView.text)
    }
    
    @objc func onClickCancel() {
        cancelHandler?()
    }
    
    func show(to view: UIView) {
        view.addSubview(self)
        autoCenterInSuperview()
        autoSetDimension(.width, toSize: 320)
        alpha = 0.0
        fadeIn()
    }
    
    func hide() {
        contentTextView.resignFirstResponder()
        fadeOut() {
            self.removeFromSuperview()
        }
    }
}

extension Alert {
    
    class func show(title: String? = nil,
                    content: String? = nil,
                    confirm: String = "确认",
                    cancel: String = "取消",
                    mask: Bool = false,
                    to view: UIView,
                    cancelHandler: EmptyBlock? = nil,
                    confirmHandler: StringBlock? = nil) {
        let params = Alert.Params(title: title,
                                        content: content,
                                        showCancel: !cancel.isEmpty,
                                        cancelText: cancel,
                                        cancelColor: "#000000",
                                        confirmText: confirm,
                                        confirmColor: "#576B95",
                                        editable: false,
                                        placeholderText: nil)
        let alert = Alert(params: params)
        var subView: TransitionView = alert
        if mask {
            subView = CoverView(contentView: alert)
        }
        alert.confirmHandler = { text in
            subView.hide()
            confirmHandler?(text)
        }
        alert.cancelHandler = {
            subView.hide()
            cancelHandler?()
        }
        subView.show(to: view)
    }
}


extension Alert: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        placeholderLabel.isHidden = !text.isEmpty
    }
}
