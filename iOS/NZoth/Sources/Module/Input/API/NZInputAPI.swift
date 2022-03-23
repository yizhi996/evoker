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

    func onInvoke(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        DispatchQueue.main.async {
            switch self {
            case .insertTextArea:
                insertTextArea(args: args, bridge: bridge)
            case .insertInput:
                insertInput(args: args, bridge: bridge)
            case .operateInput:
                operateInput(args: args, bridge: bridge)
            }
        }
    }
    
    private func insertTextArea(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct InsertTextAreaParams: Decodable  {
            let parentId: String
            let inputId: Int
            let text: String
            let placeholder: String
            var focus: Bool
            let maxlength: Int
            let adjustPosition: Bool
            let autoHeight: Bool
            let disableDefaultPadding: Bool
            let confirmType: ConfirmType
            let style: NZInputStyle
            let placeholderStyle: NZInputPlaceholderStyle
            
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
        }
        
        guard let appService = bridge.appService else { return }
        
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
        
        guard let params: InsertTextAreaParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let input = NZTextView(frame: CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height))
        input.needFocus = params.focus
        input.inputId = params.inputId
        input.adjustPosition = params.adjustPosition
        input.maxLength = params.maxlength
        input.isAutoHeight = params.autoHeight
        
        input.textView.font = UIFont.systemFont(ofSize: params.style.fontSize,
                                                weight: params.style.fontWeight.toNatively())
        input.textView.isScrollEnabled = !params.autoHeight
        input.textView.text = params.text
        input.textView.textColor = params.style.color.hexColor()
        input.textView.textAlignment = params.style.textAlign.toNatively()
        input.textView.returnKeyType = params.confirmType.toNatively()
        if params.disableDefaultPadding {
            input.textView.textContainerInset = .zero
        }
        
        input.placeholderLabel.text = params.placeholder
        input.placeholderLabel.font = UIFont.systemFont(ofSize: params.placeholderStyle.fontSize,
                                                        weight: params.placeholderStyle.fontWeight.toNatively())
        input.placeholderLabel.textColor = params.placeholderStyle.color.hexColor()
        input.placeholderLabel.autoPinEdgesToSuperviewEdges(with: input.textView.textContainerInset, excludingEdge: .bottom)
         
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
        input.autoPinEdgesToSuperviewEdges()
        
        inputModule.inputs.set(page.pageId, params.inputId, value: input)

        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func insertInput(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
        struct InsertFieldParams: Decodable  {
            let parentId: String
            let inputId: Int
            let text: String
            let placeholder: String
            let type: KeyboardType
            let password: Bool
            let focus: Bool
            let maxlength: Int
            let adjustPosition: Bool
            let confirmType: ConfirmType
            let style: NZInputStyle
            let placeholderStyle: NZInputPlaceholderStyle
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
        
        guard let appService = bridge.appService else { return }
        
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
        
        guard let params: InsertFieldParams = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        guard let container = webView.findTongCengContainerView(tongcengId: params.parentId) else {
            let error = NZError.bridgeFailed(reason: .tongCengContainerViewNotFound(params.parentId))
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let rect = CGRect(x: 0, y: 0, width: container.frame.width, height: container.frame.height)
        let input = NZTextFieldView(frame: rect)
        input.needFocus = params.focus
        input.inputId = params.inputId
        input.maxLength = params.maxlength
        input.adjustPosition = params.adjustPosition
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
            input.textField.resignFirstResponder()
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
        input.autoPinEdgesToSuperviewEdges()
        
        inputModule.inputs.set(page.pageId, params.inputId, value: input)
        
        bridge.invokeCallbackSuccess(args: args)
    }
    
    private func operateInput(args: NZJSBridge.InvokeArgs, bridge: NZJSBridge) {
        
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
            case becomeFirstResponder
        }
        
        guard let appService = bridge.appService else { return }
        
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
        case .becomeFirstResponder:
            input.input.becomeFirstResponder()
        }
        
        bridge.invokeCallbackSuccess(args: args)
    }
}
