//
//  JavaScriptGenerator.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation

struct JavaScriptGenerator {
    
    static func injectCSS(path: String) -> String {
        let script =
        """
        var link = document.createElement("link");
        link.rel="stylesheet";
        link.type="text/css";
        link.href="\(path)";
        document.head.appendChild(link);
        """
        return script
    }
}
