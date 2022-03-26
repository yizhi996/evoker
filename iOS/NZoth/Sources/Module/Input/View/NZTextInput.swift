//
//  NZTextInput.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol NZTextInput: UIView {
    
    var onFocus: NZEmptyBlock? { get set }
    
    var onBlur: NZEmptyBlock? { get set }
    
    var textChanged: NZStringBlock? { get set }
    
    var onKeyboardReturn: NZEmptyBlock? { get set }
    
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

struct NZInputStyle: Decodable {
    let width: CGFloat
    let height: CGFloat
    let color: String
    let fontSize: CGFloat
    let fontWeight: NZInputFontWeight
    let textAlign: NZInputTextAlign
    let lineHeight: CGFloat
}

struct NZInputPlaceholderStyle: Decodable {
    let color: String
    let fontSize: CGFloat
    let fontWeight: NZInputFontWeight
}

enum NZInputFontWeight: String, Decodable {
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

enum NZInputTextAlign: String, Decodable {
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
