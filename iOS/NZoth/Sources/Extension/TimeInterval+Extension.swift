//
//  TimeInterval+Extension.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

extension TimeInterval {
    
    func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        let seconds = Int(self)
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func secondsToHoursMinutesSecondsDisplay () -> String {
        let (h, m, s) = secondsToHoursMinutesSeconds()
        var result = String(format: "%02d:%02d", m, s)
        if h > 0 {
            result = String(format: "%02d:", h) + result
        }
        return result
    }
}
