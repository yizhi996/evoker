//
//  NZInputAPI.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

enum NZInputAPI: String, NZBuiltInAPI {
    
    case insertTextArea
    case insertInput
    case operateInput
    case hideKeyboard

    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .insertTextArea:
                insertTextArea(appService: appService, bridge: bridge, args: args)
            case .insertInput:
                insertInput(appService: appService, bridge: bridge, args: args)
            case .operateInput:
                operateInput(appService: appService, bridge: bridge, args: args)
            case .hideKeyboard:
                hideKeyboard(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func insertTextArea(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable {
            let parentId: String
            let inputId: Int
            let text: String
            let placeholder: String
            let focus: Bool
            let maxlength: Int
            let adjustPosition: Bool
            let style: NZInputStyle
            let placeholderStyle: NZInputPlaceholderStyle
            let disabled: Bool
            let cursor: Int
            let selectionStart: Int
            let selectionEnd: Int
            let confirmHold: Bool
            let holdKeyboard: Bool
            let cursorSpacing: CGFloat
            let autoHeight: Bool
            let disableDefaultPadding: Bool
            let confirmType: NZTextView.ConfirmType
            let showConfirmBar: Bool
        }
        
        guard let inputModule: NZInputModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZInputModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let input = NZTextView(frame: CGRect(x: 0, y: 0, width: params.style.width, height: params.style.height))
        input.needFocus = params.focus
        input.inputId = params.inputId
        input.maxLength = params.maxlength
        input.adjustPosition = params.adjustPosition
        input.selectionStart = params.selectionStart
        input.selectionEnd = params.selectionEnd
        input.cursor = params.cursor
        input.confirmHold = params.confirmHold
        input.cursorSpacing = params.cursorSpacing
        input.holdKeyboard = params.holdKeyboard
        input.isAutoHeight = params.autoHeight
        input.textView.isEditable = !params.disabled
        input.textView.font = UIFont.systemFont(ofSize: params.style.fontSize,
                                                weight: params.style.fontWeight.toNatively())
        input.textView.text = params.text
        input.textView.textColor = params.style.color.hexColor()
        input.textView.textAlignment = params.style.textAlign.toNatively()
        input.textView.returnKeyType = params.confirmType.toNatively()
        if params.showConfirmBar {
            let accessoryView = NZTextInputCompleteView()
            accessoryView.onClick = { [unowned input] in
                input.onKeyboardReturn?()
                input.endEdit()
            }
            input.textView.inputAccessoryView = accessoryView
        }
        if params.disableDefaultPadding {
            input.textView.textContainerInset = .zero
        }
        
        input.placeholderLabel.text = params.placeholder
        input.placeholderLabel.font = UIFont.systemFont(ofSize: params.placeholderStyle.fontSize,
                                                        weight: params.placeholderStyle.fontWeight.toNatively())
        input.placeholderLabel.textColor = params.placeholderStyle.color.hexColor()
        input.placeholderLabel.textAlignment = params.style.textAlign.toNatively()
        var containerInset = input.textView.textContainerInset
        containerInset.left += input.textView.textContainer.lineFragmentPadding
        containerInset.right += input.textView.textContainer.lineFragmentPadding
        input.placeholderLabel.autoPinEdgesToSuperviewEdges(with: containerInset, excludingEdge: .bottom)
        input.placeholderLabel.isHidden = !params.text.isEmpty
        
        input.onFocus = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onShowSubscribeKey, data: message)
        }
        
        input.onBlur = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onHideSubscribeKey, data: message)
        }
        
        input.textChanged = { text in
            let message: [String: Any] = ["inputId": params.inputId, "value": text]
            bridge.subscribeHandler(method: KeyboardManager.setValueSubscribeKey, data: message)
        }
        
        input.onKeyboardReturn = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onConfirmSubscribeKey, data: message)
        }
        
        input.textHeightChange = { height, lineCount in
            let message: [String: Any] = ["inputId": params.inputId, "height": height, "lineCount": lineCount]
            bridge.subscribeHandler(method: NZTextView.heightChangeSubscribeKey, data: message)
        }
        
        container.addSubview(input)
        
        inputModule.inputs.set(page.pageId, params.inputId, value: input)
        
        let height = input.getContentHeight()
        let lineCount = Int(floor(height / input.textView.font!.lineHeight))
        bridge.invokeCallbackSuccess(args: args, result: ["height": height,
                                                          "lineCount": lineCount])
    }
    
    private func insertInput(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable  {
            let parentId: String
            let inputId: Int
            let text: String
            let placeholder: String
            let type: NZTextFieldView.KeyboardType
            let password: Bool
            let focus: Bool
            let maxlength: Int
            let adjustPosition: Bool
            let confirmType: NZTextFieldView.ConfirmType
            let style: NZInputStyle
            let placeholderStyle: NZInputPlaceholderStyle
            let disabled: Bool
            let cursor: Int
            let selectionStart: Int
            let selectionEnd: Int
            let confirmHold: Bool
            let holdKeyboard: Bool
            let cursorSpacing: CGFloat
        }
        
        guard let inputModule: NZInputModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZInputModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }

        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let rect = CGRect(x: 0, y: 0, width: params.style.width, height: params.style.height)
        let input = NZTextFieldView(frame: rect)
        input.needFocus = params.focus
        input.inputId = params.inputId
        input.maxLength = params.maxlength
        input.adjustPosition = params.adjustPosition
        input.selectionStart = params.selectionStart
        input.selectionEnd = params.selectionEnd
        input.cursor = params.cursor
        input.confirmHold = params.confirmHold
        input.cursorSpacing = params.cursorSpacing
        input.holdKeyboard = params.holdKeyboard
        input.textField.isEnabled = !params.disabled
        input.textField.text = params.text
        input.textField.textColor = params.style.color.hexColor()
        input.textField.font = UIFont.systemFont(ofSize: params.style.fontSize,
                                                 weight: params.style.fontWeight.toNatively())
        input.textField.textAlignment = params.style.textAlign.toNatively()
        
        let placeholderFont = UIFont.systemFont(ofSize: params.placeholderStyle.fontSize,
                                                weight: params.placeholderStyle.fontWeight.toNatively())
        let placeholderAttributes: [NSAttributedString.Key : Any] = [.font: placeholderFont,
                                                                        .foregroundColor: params.placeholderStyle.color.hexColor()]
        input.textField.attributedPlaceholder = NSAttributedString(string: params.placeholder,
                                                                   attributes: placeholderAttributes)
        input.textField.isSecureTextEntry = params.password
        input.textField.returnKeyType = params.confirmType.toNatively()
        input.textField.keyboardType = params.type.toNatively()
        
        input.textChanged = { text in
            let message: [String: Any] = ["inputId": params.inputId, "value": text]
            bridge.subscribeHandler(method: KeyboardManager.setValueSubscribeKey, data: message)
        }
        
        input.onKeyboardReturn = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onConfirmSubscribeKey, data: message)
        }
        
        input.onFocus = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onShowSubscribeKey, data: message)
        }
        
        input.onBlur = {
            let message: [String: Any] = ["inputId": params.inputId]
            bridge.subscribeHandler(method: KeyboardManager.onHideSubscribeKey, data: message)
        }
        
        container.addSubview(input)
        
        inputModule.inputs.set(page.pageId, params.inputId, value: input)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateInput(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        
        struct Params: Decodable  {
            let inputId: Int
            let method: Method
            let data: [String: Any]
            
            enum CodingKeys: String, CodingKey {
                case inputId, method, data
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                inputId = try container.decode(Int.self, forKey: .inputId)
                method = try container.decode(Method.self, forKey: .method)
                data = try container.decode([String: Any].self, forKey: .data)
            }
        }
        
        enum Method: String, Decodable {
            case changeValue
            case focus
            case blur
            case update
            case updateStyle
            case updatePlaceholderStyle
        }
        
        guard let inputModule: NZInputModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZInputModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }

        guard let webView = bridge.container as? NZWebView else {
            let error = NZError.bridgeFailed(reason: .webViewNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let page = webView.page else {
            let error = NZError.bridgeFailed(reason: .pageNotFound)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let params: Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let input = inputModule.inputs.get(page.pageId, params.inputId) else {
            let error = NZError.bridgeFailed(reason: .inputNotFound(params.inputId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        switch params.method {
        case .changeValue:
            if let text = params.data["text"] as? String {
                input.setText(text)
            }
        case .focus:
            input.startEdit()
        case .blur:
            input.endEdit()
        case .update:
            if let input = input as? NZTextView {
                struct Params: Decodable {
                    let placeholder: String
                    let maxlength: Int
                    let adjustPosition: Bool
                    let confirmType: NZTextView.ConfirmType
                    let disabled: Bool
                    let cursor: Int
                    let selectionStart: Int
                    let selectionEnd: Int
                    let confirmHold: Bool
                    let holdKeyboard: Bool
                    let cursorSpacing: CGFloat
                    let showConfirmBar: Bool
                    let autoHeight: Bool
                    let disableDefaultPadding: Bool
                }
                
                if let params: Params = params.data.toModel() {
                    input.maxLength = params.maxlength
                    input.adjustPosition = params.adjustPosition
                    input.selectionStart = params.selectionStart
                    input.selectionEnd = params.selectionEnd
                    input.cursor = params.cursor
                    input.confirmHold = params.confirmHold
                    input.cursorSpacing = params.cursorSpacing
                    input.holdKeyboard = params.holdKeyboard
                    input.isAutoHeight = params.autoHeight
                    input.textView.isEditable = !params.disabled
                    input.placeholderLabel.text = params.placeholder
                    input.textView.returnKeyType = params.confirmType.toNatively()
                    if params.showConfirmBar {
                        let accessoryView = NZTextInputCompleteView()
                        accessoryView.onClick = { [unowned input] in
                            input.onKeyboardReturn?()
                            input.endEdit()
                        }
                        input.textView.inputAccessoryView = accessoryView
                    } else {
                        input.textView.inputAccessoryView = nil
                    }
                }
            } else if let input = input as? NZTextFieldView {
                struct Params: Decodable {
                    let type: NZTextFieldView.KeyboardType
                    let placeholder: String
                    let password: Bool
                    let maxlength: Int
                    let adjustPosition: Bool
                    let confirmType: NZTextFieldView.ConfirmType
                    let disabled: Bool
                    let cursor: Int
                    let selectionStart: Int
                    let selectionEnd: Int
                    let confirmHold: Bool
                    let holdKeyboard: Bool
                    let cursorSpacing: CGFloat
                }
                
                if let params: Params = params.data.toModel() {
                    input.maxLength = params.maxlength
                    input.adjustPosition = params.adjustPosition
                    input.selectionStart = params.selectionStart
                    input.selectionEnd = params.selectionEnd
                    input.cursor = params.cursor
                    input.confirmHold = params.confirmHold
                    input.cursorSpacing = params.cursorSpacing
                    input.holdKeyboard = params.holdKeyboard
                    input.textField.isEnabled = !params.disabled
                    input.textField.placeholder = params.placeholder
                    input.textField.isSecureTextEntry = params.password
                    input.textField.returnKeyType = params.confirmType.toNatively()
                    input.textField.keyboardType = params.type.toNatively()
                }
            }
        case .updateStyle:
            if let style: NZInputStyle = params.data.toModel() {
                let rect = CGRect(x: 0, y: 0, width: style.width, height: style.height)
                input.frame = rect
                if let input = input as? NZTextFieldView {
                    input.textField.textColor = style.color.hexColor()
                    input.textField.font = UIFont.systemFont(ofSize: style.fontSize,
                                                             weight: style.fontWeight.toNatively())
                    input.textField.textAlignment = style.textAlign.toNatively()
                } else if let input = input as? NZTextView {
                    input.textView.font = UIFont.systemFont(ofSize: style.fontSize,
                                                            weight: style.fontWeight.toNatively())
                    input.textView.textColor = style.color.hexColor()
                    input.textView.textAlignment = style.textAlign.toNatively()
                    input.placeholderLabel.textAlignment = style.textAlign.toNatively()
                }
            }
        case .updatePlaceholderStyle:
            if let style: NZInputPlaceholderStyle = params.data.toModel() {
                if let input = input as? NZTextFieldView {
                    let font = UIFont.systemFont(ofSize: style.fontSize, weight: style.fontWeight.toNatively())
                    let attributes: [NSAttributedString.Key : Any] = [.font: font,
                                                                      .foregroundColor: style.color.hexColor()]
                    let string = input.textField.attributedPlaceholder?.string ?? ""
                    input.textField.attributedPlaceholder = NSAttributedString(string: string, attributes: attributes)
                } else if let input = input as? NZTextView {
                    input.placeholderLabel.font = UIFont.systemFont(ofSize: style.fontSize,
                                                                    weight: style.fontWeight.toNatively())
                    input.placeholderLabel.textColor = style.color.hexColor()
                }
            }
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func hideKeyboard(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        guard let module: NZInputModule = appService.getModule() else {
            let error = NZError.bridgeFailed(reason: .moduleNotFound(NZInputModule.name))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        if let needResignFirstInput = module.inputs.all().first(where: { $0.isFirstResponder }) {
            needResignFirstInput.endEdit()
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
