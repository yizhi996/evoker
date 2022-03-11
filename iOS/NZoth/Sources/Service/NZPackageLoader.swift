//
//  NZPackageLoader.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import Zip

class NZPackageLoader {
    
    class func loadBundleSDK() {
        Zip.addCustomFileExtension("nzpkg")
        
        let version = Constant.jsSDKVersion
        let url = Constant.assetsBundle.url(forResource: "nzoth-sdk-\(version)", withExtension: "nzpkg")!
        let dest = FilePath.jsSDK(version: version)
        do {
            try FileManager.default.createDirectory(at: dest, withIntermediateDirectories: true, attributes: nil)
            try Zip.unzipFile(url,
                              destination: dest,
                              overwrite: true,
                              password: nil,
                              progress: { progress in
                print(progress)
            }, fileOutputHandler: nil)
        } catch {
            print("unpack fail: \(error)")
        }
    }
    
}
