//
//  ScanCodeViewModel.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import ZLPhotoBrowser

class ScanCodeViewModel {
    
    struct Params: Decodable {
        let onlyFromCamera: Bool
        let scanType: [CameraEngine.ScanType]
    }
    
    var scanCompletionHandler: ((String, String) -> Void)?
    
    var cancelHandler: EmptyBlock?
    
    var isScanned = false
    
    let cameraEngine: CameraEngine
    let params: Params
    init(params: Params) {
        self.params = params
        let options = CameraEngine.Options(mode: .scanCode,
                                             resolution: .high,
                                             devicePosition: .back,
                                             flashMode: .off,
                                             scanType: params.scanType)
        cameraEngine = CameraEngine(options: options)
        cameraEngine.scanCodeHandler = { [unowned self] value, type in
            if isScanned {
                return
            }
            isScanned = true
            
            self.scanCompletionHandler?(value, converScanType(type))
            self.cancelHandler = nil
            
            DispatchQueue.main.async {
                self.playSound()
                Engine.shared.currentApp?.rootViewController?.popViewController(animated: true)
            }
        }
    }
    
    func checkCameraAuth(completion: BoolBlock?) {
        switch PrivacyPermission.camera {
        case .authorized:
            cameraEngine.startRunning()
            completion?(true)
        case .notDetermined:
            PrivacyPermission.requestCamera {
                self.checkCameraAuth(completion: completion)
            }
        case .denied:
            completion?(false)
        }
    }
    
    func showCameraNotAuthAlert(to view: UIView) {
        let appName = Constant.hostName
        Alert.show(title: "相机权限未开启",
                         content: "请在 iPhone 的“设置-隐私-\(appName)”选项中，允许\(appName)访问你的摄像头。",
                         confirm: "前往设置",
                         cancel: "我知道了",
                         to: view, cancelHandler: nil) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(settingsUrl) else { return }
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func converScanType(_ type: AVMetadataObject.ObjectType) -> String {
        var scanType = ""
        switch type {
        case .qr:
            scanType = "QR_CODE"
        case .aztec:
            scanType = "AZTEC"
        case .code39:
            scanType = "CODE_39"
        case .code93:
            scanType = "CODE_93"
        case .code128:
            scanType = "CODE_128"
        case .dataMatrix:
            scanType = "DATA_MATRIX"
        case .ean8:
            scanType = "EAN_8"
        case .ean13:
            scanType = "EAN_13"
        case .itf14:
            scanType = "ITF"
        case .pdf417:
            scanType = "PDF_417"
        case .upce:
            scanType = "UPC_E"
        default:
            scanType = "UNKNOWN"
        }
        return scanType
    }
    
    var player: AVPlayer?
    
    func playSound() {
        guard let url = Constant.assetsBundle.url(forResource: "scan-code", withExtension: "wav") else { return }
        player = AVPlayer(url: url)
        player?.play()
    }
    
    func showChooseImage(to viewController: UIViewController) {
        let ps = ZLPhotoPreviewSheet()
        let config = ZLPhotoConfiguration.default()
        config.allowSelectOriginal = false
        config.allowTakePhotoInLibrary = false
        config.allowSelectVideo = false
        config.allowEditImage = false
        config.maxSelectCount = 1
        ps.selectImageBlock = { [unowned self] images, _, _ in
            guard let image = images.first,
                  let ciImage = CIImage(image: image) else { return }
            let detector = CIDetector(ofType: CIDetectorTypeQRCode,
                                      context: nil,
                                      options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
            let features = detector?.features(in: ciImage) ?? []
            if let result = features.first as? CIQRCodeFeature, let value = result.messageString {
                self.playSound()
                self.scanCompletionHandler?(value, "QR_CODE")
                if let navigationController = Engine.shared.currentApp?.rootViewController {
                    let index = navigationController.viewControllers.count - 2
                    let viewController = navigationController.viewControllers[index]
                    navigationController.popToViewController(viewController, animated: true)
                }
            } else {
                Toast(params: Toast.Params(title: "未发现 二维码 / 条码",
                                               icon: .none,
                                               image: nil,
                                               duration: 1000,
                                               mask: true)).show(to: viewController.view)
            }
        }
        ps.showPhotoLibrary(sender: viewController)
    }
}

extension ScanCodeViewModel {
    
    func generateViewController() -> UIViewController {
        return ScanCodeViewController(viewModel: self)
    }
}
