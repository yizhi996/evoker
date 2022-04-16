//
//  NZScanEvent.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum NZScanAPI: String, NZBuiltInAPI {
    
    case scanCode
    
    func onInvoke(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .scanCode:
                scanCode(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func scanCode(appService: NZAppService, bridge: NZJSBridge, args: NZJSBridge.InvokeArgs) {        
        guard let params: NZScanCodeViewModel.Params = args.paramsString.toModel() else {
            let error = NZError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let viewModel = NZScanCodeViewModel(params: params)
        viewModel.scanCompletionHandler = { value, type in
            bridge.invokeCallbackSuccess(args: args, result: ["result": value, "scanType": type])
        }
        viewModel.cancelHandler = {
            let error = NZError.bridgeFailed(reason: .cancel)
            bridge.invokeCallbackFail(args: args, error: error)
        }
        let viewController = viewModel.generateViewController()
        appService.rootViewController?.pushViewController(viewController, animated: true)
    }
    
}
