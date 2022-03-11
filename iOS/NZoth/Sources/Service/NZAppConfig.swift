//
//  NZAppConfig.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

public struct NZAppConfig: Decodable {
    
    public let appId: String
    public let pages: [NZAppPageInfo]
    public let tabBar: NZAppTabBarInfo?
    public let window: NZAppStyle?
    
    static func load(appId: String, envVersion: NZAppEnvVersion) -> NZAppConfig? {
        let configURL = FilePath.appDist(appId: appId, envVersion: envVersion).appendingPathComponent("app.json")
        guard let configData = FileManager.default.contents(atPath: configURL.path) else { return nil }
        return configData.toModel()
    }
}

public struct NZAppStyle: Decodable {
    
    public enum NavigationStyle: String, Codable {
        case `default` = "default"
        case custom = "custom"
    }
    
    public let navigationBarBackgroundColor: String?
    public let navigationBarTextStyle: String?
    public var navigationBarTitleText: String?
    public let navigationStyle: NavigationStyle?
    public let backgroundColor: String?
    
    public enum PageOrientation: String, Codable {
        case auto
        case portrait
        case landspace
    }
    
    public let pageOrientation: PageOrientation?
}

public typealias NZPageStyle = NZAppStyle

public struct NZAppTabBarInfo: Decodable {
    public let color: String
    public let selectedColor: String
    public let backgroundColor: String
    public let list: [NZAppTabBarItem]
}

public struct NZAppTabBarItem: Decodable {
    public let path: String
    public let text: String
    public let iconPath: String?
    public let selectedIconPath: String?
}

public struct NZAppPageInfo: Decodable {
    public let component: String
    public var path: String
    public var style: NZAppStyle?

}

public enum NZAppEnvVersion: String {
    
    case develop
    
    case trail
    
    case release
  
}
