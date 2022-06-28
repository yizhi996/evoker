//
//  NSAttributedString+Extension.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    var rangeOfAll: NSRange {
        return NSRange(location: 0, length: string.count)
    }
    
    func calcHeight(width: CGFloat) -> CGFloat {
        let rect = boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return rect.height
    }
}
