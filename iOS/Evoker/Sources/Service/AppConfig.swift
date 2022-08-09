//
//  AppConfig.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public struct AppConfig: Decodable {
    
    public let appId: String
    
    public let pages: [Page]
    
    public let tabBar: TabBar?
    
    public let window: Style?
    
    public struct Page: Decodable {
        public var path: String
        
        public var style: Style?

    }

    public struct TabBar: Decodable {
        public let color: String?
        
        public let selectedColor: String?
        
        public let backgroundColor: String?
        
        public let borderStyle: BorderStyle?
        
        public let list: [Item]
        
        public enum BorderStyle: String, Decodable {
            case white
            
            case black
        }
        
        public struct Item: Decodable {
            public let path: String
            
            public let text: String
            
            public let iconPath: String?
            
            public let selectedIconPath: String?
        }
    }

    public struct Style: Decodable {
        
        public enum NavigationStyle: String, Codable {
            case `default` = "default"
            case custom = "custom"
        }
        
        public enum PageOrientation: String, Codable {
            case auto
            case portrait
            case landspace
        }
        
        public enum NavigationBarTextStyle: String, Codable {
            case white
            case black
            
            func toColor() -> UIColor {
                switch self {
                case .white:
                    return .white
                case .black:
                    return .black
                }
            }
        }
        
        public let pageOrientation: PageOrientation?
        
        public let navigationBarBackgroundColor: String?
        
        public var navigationBarTextStyle: NavigationBarTextStyle?
        
        public var navigationBarTitleText: String?
        
        public let navigationStyle: NavigationStyle?
        
        public let backgroundColor: String?
        
    }
    
    static func load(appId: String, envVersion: AppEnvVersion) -> AppConfig? {
        let configURL = FilePath.appDist(appId: appId, envVersion: envVersion).appendingPathComponent("app.json")
        guard let configData = FileManager.default.contents(atPath: configURL.path) else { return nil }
        return configData.toModel()
    }
}
