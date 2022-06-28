//
//  NativelyContainerView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public final class NativelyContainerView: UIView {
    
    public override func conforms(to aProtocol: Protocol) -> Bool {
        if NSStringFromProtocol(aProtocol) == "WKNativelyInteractible" {
            return true
        }
        return super.conforms(to: aProtocol)
    }
}
