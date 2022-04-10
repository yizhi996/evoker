//
//  NZTransitionView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

protocol NZTransitionView: UIView {
    
    func show(to view: UIView)
    
    func hide()
}
