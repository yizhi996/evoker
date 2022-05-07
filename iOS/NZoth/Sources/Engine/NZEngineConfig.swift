//
//  NZEngineConfig.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public struct NZEngineConfig {
 
    public var devServer = NZDevServerConfig()
    
    public var webPageClass: NZWebPage.Type = NZWebPage.self
    
    public var browserPageClass: NZBrowserPage.Type = NZBrowserPage.self
    
    public init() {
        
    }
    
}
