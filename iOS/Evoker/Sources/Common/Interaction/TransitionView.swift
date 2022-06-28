//
//  TransitionView.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

protocol TransitionView: UIView {
    
    func show(to view: UIView)
    
    func hide()
}
