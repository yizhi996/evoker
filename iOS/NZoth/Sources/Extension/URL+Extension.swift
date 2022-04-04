//
//  URL+Extension.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation

extension URL {
    
    var fileSize: Int {
        guard isFileURL else { return 0 }
        let resourceValues = try? resourceValues(forKeys: [.fileSizeKey])
        return resourceValues?.fileSize ?? 0
    }
}
