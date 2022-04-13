//
//  NZSettingViewModel.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit

class NZSettingViewModel {
    
    let tableViewInfo = NZStaticTableViewInfo()
    let sectionInfo: NZStaticTableViewSectionInfo
    
    let authorizations: [(key: String, value: Bool)]
    
    let appService: NZAppService
    
    var locationKey = "deny"
    
    var popViewControllerHandler: (() -> Void)?
    
    init(appService: NZAppService) {
        self.appService = appService
        
        sectionInfo = NZStaticTableViewSectionInfo(header: "允许“\(appService.appInfo.appName)”使用")
        let (auths, _) = appService.storage.getAllAuthorization()
        
        let validScopes = ["scope.userInfo",
                           "scope.userLocation",
                           "scope.userLocationBackground",
                           "scope.record",
                           "scope.camera",
                           "scope.writePhotosAlbum"]
        
        authorizations = auths.filter { validScopes.contains($0.key) }.sorted { lhs, rhs in
            return validScopes.firstIndex(of: lhs.key)! < validScopes.firstIndex(of: rhs.key)!
        }
        
        var locationCellInfo: NZStaticTableViewCellInfo?
        
        for (i, (scope, authorized)) in authorizations.enumerated() {
            if !scope.starts(with: "scope.userLocation") {
                let cellInfo = NZStaticTableViewCellInfo()
                    .titleColor(UIColor.color("#000".hexColor(alpha: 0.9), dark: "#fff".hexColor(alpha: 0.9)))
                    .height(56)
                    .selectionStyle(.none)
                    
                let switchView = UISwitch()
                switchView.tag = i
                switchView.isOn = authorized
                switchView.addTarget(self, action: #selector(authorizationValueChange(_:)), for: .valueChanged)
                cellInfo.accessoryView(switchView)
                
                switch scope {
                case "scope.userInfo":
                    cellInfo
                        .title("用户信息")
                case "scope.record":
                    cellInfo
                        .title("麦克风")
                case "scope.camera":
                    cellInfo
                        .title("摄像头")
                case "scope.writePhotosAlbum":
                    cellInfo
                        .title("保存到相册")
                default:
                    break
                }
                sectionInfo.append(cellInfo)
            } else {
                var righeValue: String = "不允许"
                if authorizations.first(where: { $0.key == "scope.userLocationBackground" && $0.value }) != nil {
                    righeValue = "使用时与离开后"
                    locationKey = "back"
                } else if authorizations.first(where: { $0.key == "scope.userLocation" && $0.value }) != nil {
                    righeValue = "使用时"
                    locationKey = "front"
                }
                
                if let locationCellInfo = locationCellInfo {
                    locationCellInfo.rightValue(righeValue)
                } else {
                    let cellInfo = NZStaticTableViewCellInfo()
                        .titleColor(UIColor.color("#000".hexColor(alpha: 0.9), dark: "#fff".hexColor(alpha: 0.9)))
                        .height(56)
                        .selectionStyle(.none)
                        .title("位置信息")
                        .rightValue(righeValue)
                        .selectionStyle(.default)
                        .rightValueColor(UIColor.color("#000".hexColor(alpha: 0.5), dark: "#fff".hexColor(alpha: 0.5)))
                        .didSelect { [unowned self] cellInfo in
                            let viewModel = NZLocationSettingViewModel(current: locationKey)
                            viewModel.popViewControllerHandler = { selected in
                                if selected != self.locationKey {
                                    self.locationAuthorizationValueChange(key: selected, cellInfo: cellInfo)
                                }
                            }
                            appService.rootViewController!.pushViewController(viewModel.generateViewController(),
                                                                              animated: true)
                        }
                    sectionInfo.append(cellInfo)
                    locationCellInfo = cellInfo
                }
            }
        }
        
        tableViewInfo.append(sectionInfo)
    }
    
    @objc
    func authorizationValueChange(_ sender: UISwitch) {
        let (scope, _) = authorizations[sender.tag]
        
        let viewController = appService.rootViewController!.viewControllers.last!
        
        NZToast(params: NZToast.Params(title: "正在设置",
                                       icon: .loading,
                                       image: nil,
                                       duration: 0,
                                       mask: true)).show(to: viewController.view)
        if appService.storage.setAuthorization(scope, authorized: sender.isOn) != nil {
            NZToast(params: NZToast.Params(title: "设置失败",
                                           icon: .error,
                                           image: nil,
                                           duration: 1500,
                                           mask: true)).show(to: viewController.view)
        }
    }
    
    func locationAuthorizationValueChange(key: String, cellInfo: NZStaticTableViewCellInfo) {
        let viewController = appService.rootViewController!.viewControllers.last!
        
        NZToast(params: NZToast.Params(title: "正在设置",
                                       icon: .loading,
                                       image: nil,
                                       duration: 0,
                                       mask: true)).show(to: viewController.view)
        
        func showFailToast() {
            NZToast(params: NZToast.Params(title: "设置失败",
                                           icon: .error,
                                           image: nil,
                                           duration: 1500,
                                           mask: true)).show(to: viewController.view)
        }
        
        if key == "deny" {
            if appService.storage.setAuthorization("scope.userLocation", authorized: false) == nil &&
                appService.storage.setAuthorization("scope.userLocationBackground", authorized: false) == nil {
                locationKey = key
                cellInfo.rightValue("不允许")
                tableViewInfo.tableView.reloadData()
            } else {
                showFailToast()
            }
        }  else if key == "front" {
            if appService.storage.setAuthorization("scope.userLocation", authorized: true) == nil &&
                appService.storage.setAuthorization("scope.userLocationBackground", authorized: false) == nil {
                locationKey = key
                cellInfo.rightValue("使用时")
                tableViewInfo.tableView.reloadData()
            } else {
                showFailToast()
            }
        } else if key == "back" {
            if appService.storage.setAuthorization("scope.userLocation", authorized: true) == nil &&
                appService.storage.setAuthorization("scope.userLocationBackground", authorized: true) == nil {
                locationKey = key
                cellInfo.rightValue("使用时与离开后")
                tableViewInfo.tableView.reloadData()
            } else {
                showFailToast()
            }
        }
    }
}

extension NZSettingViewModel {
    
    func generateViewController() -> UIViewController {
        return NZSettingViewController(viewModel: self)
    }
}

