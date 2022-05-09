//
//  NZVideoPlayer.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation

class NZVideoPlayer: NZPlayer {
    
    var fullscreenChangeHandler: ((Bool, CGFloat) -> Void)?
    
    var waitingHandler: NZEmptyBlock?
    
}
