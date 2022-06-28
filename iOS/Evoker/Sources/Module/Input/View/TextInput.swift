//
//  TextInput.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol TextInput: UIView {
    
    var onFocus: EmptyBlock? { get set }
    
    var onBlur: EmptyBlock? { get set }
    
    var textChanged: StringBlock? { get set }
    
    var onKeyboardReturn: EmptyBlock? { get set }
    
    var field: UITextInput { get }
    
    var inputId: Int { get set }
    
    var maxLength: Int { get set }
    
    var adjustPosition: Bool { get set }
    
    var cursor: Int { get set }
    
    var selectionStart: Int { get set }
    
    var selectionEnd: Int { get set }
    
    var confirmHold: Bool { get set }
    
    var cursorSpacing: CGFloat { get set }
    
    var holdKeyboard: Bool { get set }
    
    var needFocus: Bool { get set }
    
    func setText(_ text: String)
    
    func startEdit()
    
    func endEdit()
}

struct InputStyle: Decodable {
    let width: CGFloat
    let height: CGFloat
    let color: String
    let fontSize: CGFloat
    let fontWeight: InputFontWeight
    let textAlign: InputTextAlign
    let lineHeight: CGFloat
}

struct InputPlaceholderStyle: Decodable {
    let color: String
    let fontSize: CGFloat
    let fontWeight: InputFontWeight
}

enum InputFontWeight: String, Decodable {
    case ultraLight
    case thin
    case light
    case normal
    case medium
    case semibold
    case bold
    case heavy
    case black
    
    func toNatively() -> UIFont.Weight {
        switch self {
        case .ultraLight:
            return .ultraLight
        case .thin:
            return .thin
        case .light:
            return .light
        case .normal:
            return .regular
        case .medium:
            return .medium
        case .semibold:
            return .semibold
        case .bold:
            return .bold
        case .heavy:
            return .heavy
        case .black:
            return .black
        }
    }
}

enum InputTextAlign: String, Decodable {
    case left
    case center
    case right
    
    func toNatively() -> NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
}
