//
//  Constant.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

public typealias NZEmptyBlock = () -> Void

public typealias NZBoolBlock = (Bool) -> Void

public typealias NZIntBlock = (Int) -> Void

public typealias NZStringBlock = (String) -> Void

public typealias NZCGFloatBlock = (CGFloat) -> Void

public typealias NZDoubleBlock = (Double) -> Void

public typealias NZFloatBlock = (Float) -> Void

public typealias NZURLBlock = (URL) -> Void

public typealias NZErrorBlock = (NZError?) -> Void

struct Constant {
    
    static var brand: String {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return "iPhone"
        case .pad:
            return "iPad"
        case .mac:
            return "Mac"
        default:
            return "unknown"
        }
    }
    
    static var modle: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return mirrorToString(Mirror(reflecting: systemInfo.machine))
    }
    
    static func mirrorToString(_ mirror: Mirror) -> String {
        return mirror.children.reduce("") { identifier, element in
           guard let value = element.value as? Int8, value != 0 else { return identifier }
           return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
    
    static var bundle: Bundle {
        return Bundle(for: NZEngine.self)
    }
    
    static var assetsBundle: Bundle {
        guard let path = bundle.path(forResource: "NZoth", ofType: "bundle") else {
            return bundle
        }
        return Bundle(path: path) ?? bundle
    }
    
    static var platfrom: String {
        return "iOS"
    }
    
    static var system: String {
        return "\(platfrom) \(UIDevice.current.systemVersion)"
    }
    
    static var nativeSDKVersion: String {
        return bundle.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static var hostVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    static var jsSDKVersion: String {
        return "0.1.0"
    }
    
    static var hostName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    static var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var windowWidth: CGFloat {
        return UIApplication.shared.keyWindow!.bounds.width
    }
    
    static var windowHeight: CGFloat {
        return UIApplication.shared.keyWindow!.bounds.height
    }
    
    static var windowFrame: CGRect {
        return UIApplication.shared.keyWindow!.bounds
    }
    
    static var scale: CGFloat {
        return UIScreen.main.scale
    }
    
    static var safeAreaInsets: UIEdgeInsets {
        return UIApplication.shared.keyWindow!.safeAreaInsets
    }
    
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    static var tabBarHeight: CGFloat {
        return safeAreaInsets.bottom + 48.0
    }
    
    static var navigationBarHeight: CGFloat {
        return 44.0
    }
    
    static var topHeight: CGFloat {
        return statusBarHeight + navigationBarHeight
    }
}
