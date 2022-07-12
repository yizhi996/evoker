//
//  ScanAPI.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

enum ScanAPI: String, CaseIterableAPI {
    
    case scanCode
    
    func onInvoke(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {
        DispatchQueue.main.async {
            switch self {
            case .scanCode:
                scanCode(appService: appService, bridge: bridge, args: args)
            }
        }
    }
    
    private func scanCode(appService: AppService, bridge: JSBridge, args: JSBridge.InvokeArgs) {        
        guard let params: ScanCodeViewModel.Params = args.paramsString.toModel() else {
            let error = EKError.bridgeFailed(reason: .jsonParseFailed)
            bridge.invokeCallbackFail(args: args, error: error)
            return
        }
        
        let viewModel = ScanCodeViewModel(params: params)
        viewModel.scanCompletionHandler = { value, type in
            bridge.invokeCallbackSuccess(args: args, result: ["result": value, "scanType": type])
        }
        viewModel.cancelHandler = {
            let error = EKError.bridgeFailed(reason: .cancel)
            bridge.invokeCallbackFail(args: args, error: error)
        }
        let viewController = viewModel.generateViewController()
        appService.rootViewController?.pushViewController(viewController, animated: true)
    }
    
}
