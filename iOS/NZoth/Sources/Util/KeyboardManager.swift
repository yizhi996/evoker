//
//  KeyboardManager.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public struct KeyboardTransition {
    
    public let toVisible: Bool
    
    public let fromVisible: Bool
    
    public let toFrame: CGRect
    
    public let fromFrame: CGRect
    
    public let animationDuration: TimeInterval
    
    public let animationCurve: UIView.AnimationCurve
    
    public let animationOptions: UIView.AnimationOptions
}

public protocol KeyboardObserver: AnyObject {
    
    func keyboardChanged(_ transition: KeyboardTransition)
}

public class KeyboardManager {
    
    public static let shared = KeyboardManager()
    
    public var currentTransition: KeyboardTransition?
    
    private lazy var targets = NSHashTable<AnyObject>.weakObjects()
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name:  UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name:  UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func addObserver(_ target: KeyboardObserver) {
        targets.add(target)
    }
    
    public func removeObserver(_ target: KeyboardObserver) {
        targets.remove(target)
    }
    
    @objc private func keyboardWillShow(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let keyboardBeginFrame = userInfo[UIApplication.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let keyboardEndFrame = userInfo[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let animationDuration = userInfo[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = userInfo[UIApplication.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve ?? .easeInOut
        
        let toVisible = true
        
        let opsiont = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
        let transition = KeyboardTransition(toVisible: toVisible,
                                            fromVisible: !toVisible,
                                            toFrame: keyboardEndFrame,
                                            fromFrame: keyboardBeginFrame,
                                            animationDuration: animationDuration,
                                            animationCurve: curve,
                                            animationOptions: opsiont)
        currentTransition = transition
        
        for target in targets.objectEnumerator() {
            (target as! KeyboardObserver).keyboardChanged(transition)
        }
    }
    
    @objc private func keyboardWillHide(_ notify: Notification) {
        guard let userInfo = notify.userInfo else { return }
        guard let keyboardBeginFrame = userInfo[UIApplication.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let keyboardEndFrame = userInfo[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let animationDuration = userInfo[UIApplication.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let curve = userInfo[UIApplication.keyboardAnimationCurveUserInfoKey] as? UIView.AnimationCurve ?? .easeInOut
        
        let toVisible = false
        
        let opsiont = UIView.AnimationOptions(rawValue: UInt(curve.rawValue << 16))
        let transition = KeyboardTransition(toVisible: toVisible,
                                            fromVisible: !toVisible,
                                            toFrame: keyboardEndFrame,
                                            fromFrame: keyboardBeginFrame,
                                            animationDuration: animationDuration,
                                            animationCurve: curve,
                                            animationOptions: opsiont)
        currentTransition = transition
        
        for target in targets.objectEnumerator() {
            (target as! KeyboardObserver).keyboardChanged(transition)
        }
    }
}

//MARK: NZSubscribeKey
extension KeyboardManager {
    
    public static let setValueSubscribeKey = NZSubscribeKey("WEBVIEW_KEYBOARD_SET_VALUE")
    
    public static let onShowSubscribeKey = NZSubscribeKey("WEBVIEW_KEYBOARD_ON_SHOW")
    
    public static let onHideSubscribeKey = NZSubscribeKey("WEBVIEW_KEYBOARD_ON_HIDE")
    
    public static let onConfirmSubscribeKey = NZSubscribeKey("WEBVIEW_KEYBOARD_ON_CONFIRM")
    
    public static let heightChangeSubscribeKey = NZSubscribeKey("WEBVIEW_KEYBOARD_HEIGHT_CHANGE")
}
