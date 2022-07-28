//
//  InputModule.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

class InputModule: Module {
    
    typealias PageId = Int
    
    typealias InputId = Int
    
    static var name: String {
        return "com.evokerdev.module.input"
    }
    
    static var apis: [String : API] {
        var result: [String : API] = [:]
        InputAPI.allCases.forEach { result[$0.rawValue] = $0 }
        return result
    }
    
    weak var appService: AppService?
    
    lazy var inputs: DoubleLevelDictionary<PageId, InputId, TextInput> = DoubleLevelDictionary()
    
    var prevKeyboardHeight: CGFloat = 0
    
    required init(appService: AppService) {
        self.appService = appService
        
        KeyboardManager.shared.addObserver(self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textViewDidChangeHeightNotification(_:)),
                                               name: TextView.didChangeHeightNotification,
                                               object: nil)
    }
    
    deinit {
        KeyboardManager.shared.removeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    func onUnload(_ page: Page) {
        inputs.remove(page.pageId)
    }
    
    func onPageScroll(_ page: Page) {
        guard let needResignFirstInput = first(pageId: page.pageId, where: { $0.isFirstResponder }) else { return }
        needResignFirstInput.endEdit()
    }
    
    func first(pageId: PageId, where predicate: (TextInput) throws -> Bool) rethrows -> TextInput? {
        guard let inputs = inputs.get(pageId) else { return nil }
        return try? inputs.values.first(where: predicate)
    }
    
    func last(pageId: PageId, where predicate: (TextInput) throws -> Bool) rethrows -> TextInput? {
        guard let inputs = inputs.get(pageId) else { return nil }
        return try? Array(inputs.values).last(where: predicate)
    }
    
    func allInputs(pageId: PageId) -> [TextInput] {
        guard let inputs = inputs.get(pageId) else { return [] }
        return Array(inputs.values)
    }
    
    @objc func textViewDidChangeHeightNotification(_ notify: Notification) {
        guard let appService = appService,
              let page = appService.currentPage as? WebPage,
              page.isVisibled,
              let input = notify.object as? TextView,
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

extension InputModule: KeyboardObserver {
    
    func keyboardChanged(_ transition: KeyboardTransition) {
        guard let appService = appService,
              let page = appService.currentPage as? WebPage,
              page.isVisibled else { return }
        
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
