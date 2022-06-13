//
//  NZInputModule.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class NZInputModule: NZModule {
    
    typealias PageId = Int
    
    typealias InputId = Int
    
    static var name: String {
        return "com.nozthdev.module.input"
    }
    
    static var apis: [String : NZAPI] {
        var result: [String : NZAPI] = [:]
        NZInputAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    weak var appService: NZAppService?
    
    lazy var inputs: DoubleLevelDictionary<PageId, InputId, NZTextInput> = DoubleLevelDictionary()
    
    var prevKeyboardHeight: CGFloat = 0
    
    required init(appService: NZAppService) {
        self.appService = appService
        
        KeyboardManager.shared.addObserver(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChangeHeightNotification(_:)),
                                               name: NZTextView.didChangeHeightNotification,
                                               object: nil)
    }
    
    deinit {
        KeyboardManager.shared.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func onShow(_ page: NZPage) {
        guard let needFocusInput = last(pageId: page.pageId, where: { $0.needFocus }) else { return }
        needFocusInput.startEdit()
        allInputs(pageId: page.pageId).forEach { $0.needFocus = false }
    }
    
    func onUnload(_ page: NZPage) {
        inputs.remove(page.pageId)
    }
    
    func onPageScroll(_ page: NZPage) {
        guard let needResignFirstInput = first(pageId: page.pageId, where: { $0.isFirstResponder }) else { return }
        needResignFirstInput.endEdit()
    }
    
    func first(pageId: PageId, where predicate: (NZTextInput) throws -> Bool) rethrows -> NZTextInput? {
        guard let inputs = inputs.get(pageId) else { return nil }
        return try? inputs.values.first(where: predicate)
    }
    
    func last(pageId: PageId, where predicate: (NZTextInput) throws -> Bool) rethrows -> NZTextInput? {
        guard let inputs = inputs.get(pageId) else { return nil }
        return try? Array(inputs.values).last(where: predicate)
    }
    
    func allInputs(pageId: PageId) -> [NZTextInput] {
        guard let inputs = inputs.get(pageId) else { return [] }
        return Array(inputs.values)
    }
    
    @objc func textViewDidChangeHeightNotification(_ notify: Notification) {
        guard let appService = appService,
              let page = appService.currentPage as? NZWebPage,
              page.isVisible,
              let input = notify.object as? NZTextView,
              let transition = KeyboardManager.shared.currentTransition else { return }
        var rect = input.frame
        if let selectedTextRange = input.field.selectedTextRange {
            rect = input.field.caretRect(for: selectedTextRange.end)
        }
        let inputMaxY = input.convert(rect,
                                      to: UIApplication.shared.keyWindow).maxY + input.cursorSpacing
        let keyboardY = transition.toFrame.minY
        if inputMaxY > keyboardY {
            page.webView.adjustPosition = true
            UIView.animate(withDuration: transition.animationDuration,
                           delay: 0,
                           options: transition.animationOptions) {
                page.webView.frame.origin.y -= inputMaxY - keyboardY
            }
        }
    }
}

extension NZInputModule: KeyboardObserver {
    
    func keyboardChanged(_ transition: KeyboardTransition) {
        guard let appService = appService,
              let page = appService.currentPage as? NZWebPage,
              page.isVisible else { return }
        
        let webView = page.webView
        let keyboardHeight = transition.toVisible ? transition.toFrame.height : 0
        
        let keyboardHeightUpdated = keyboardHeight != prevKeyboardHeight
        if keyboardHeightUpdated {
            prevKeyboardHeight = keyboardHeight
            
            allInputs(pageId: page.pageId).forEach { input in
                let message: [String: Any] = [
                    "inputId": input.inputId,
                    "height": keyboardHeight,
                    "duration": transition.animationDuration,
                ]
                webView.bridge.subscribeHandler(method: KeyboardManager.heightChangeSubscribeKey, data: message)
            }
            
            appService.bridge.subscribeHandler(method: KeyboardManager.heightChangeSubscribeKey,
                                               data: ["height": keyboardHeight])

        }
        
        if transition.toVisible {
            if keyboardHeightUpdated {
                if let input = first(pageId: page.pageId, where: { $0.isFirstResponder }),
                   input.adjustPosition {
                    let keyboardY = transition.toFrame.minY
                    var rect = input.frame
                    if let selectedTextRange = input.field.selectedTextRange {
                        rect = input.field.caretRect(for: selectedTextRange.end)
                    }
                    let inputMaxY = input.convert(rect,
                                                  to: UIApplication.shared.keyWindow).maxY + input.cursorSpacing
                    if inputMaxY > keyboardY {
                        webView.adjustPosition = true
                        UIView.animate(withDuration: transition.animationDuration,
                                       delay: 0,
                                       options: transition.animationOptions) {
                            webView.frame.origin.y -= inputMaxY - keyboardY
                        }
                    }
                }
            }
        } else {
            prevKeyboardHeight = 0
            if webView.adjustPosition {
                webView.adjustPosition = false
                UIView.animate(withDuration: transition.animationDuration,
                               delay: 0,
                               options: transition.animationOptions) {
                    webView.frame.origin.y = page.navigationStyle == .default ? Constant.navigationBarHeight + Constant.statusBarHeight : 0
                }
            }
        }
    }
}
