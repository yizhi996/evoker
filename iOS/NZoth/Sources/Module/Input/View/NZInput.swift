//
//  NZInput.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public protocol NZInput: UIView {
    
    var onFocus: NZEmptyBlock? { get set }
    var onBlur: NZEmptyBlock? { get set }
    var textChanged: NZStringBlock? { get set }
    var onKeyboardReturn: NZEmptyBlock? { get set }
    
    var input: UIResponder { get }
    var inputId: Int { get set }
    var maxLength: Int { get set }
    var adjustPosition: Bool { get set }
    var needFocus: Bool { get set }
    
    func setText(_ text: String)
}

struct NZInputStyle: Decodable {
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
    case normal
    case bold
    
    func toNatively() -> UIFont.Weight {
        switch self {
        case .normal:
            return .regular
        case .bold:
            return .bold
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
