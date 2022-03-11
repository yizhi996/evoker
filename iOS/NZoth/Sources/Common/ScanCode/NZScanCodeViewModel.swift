//
//  NZScanCodeViewModel.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import UIKit
import AVFoundation
import AudioToolbox

class NZScanCodeViewModel {
    
    struct Params: Decodable {
        let onlyFromCamera: Bool
        let scanType: [NZCapture.ScanType]
    }
    
    var scanCompletionHandler: ((String, String) -> Void)?
    
    var isScanned = false
    
    let cameraEngine: NZCameraEngine
    let params: Params
    init(params: Params) {
        self.params = params
        let options = NZCapture.Options(mode: .scanCode,
                                                resolution: .high,
                                                position: .back,
                                                scanType: params.scanType)
        cameraEngine = NZCameraEngine(options: options)
        cameraEngine.scanCodeHandler = { [unowned self] value, type in
            if isScanned {
                return
            }
            isScanned = true
            self.playSound()
            self.scanCompletionHandler?(value, converScanType(type))
            UIViewController.visibleViewController()?.navigationController?.popViewController(animated: true)
        }
    }
    
    func checkCameraAuth(completion: NZBoolBlock?) {
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
    
    func playSound() {
        guard let url = Constant.assetsBundle.url(forResource: "scan-code", withExtension: "wav") else { return }
        var soundID: SystemSoundID = 0
        let err = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        if err == kAudioServicesNoError {
            AudioServicesPlaySystemSoundWithCompletion(soundID) {
                AudioServicesDisposeSystemSoundID(soundID)
            }
        }
    }
}

extension NZScanCodeViewModel {
    
    func generateViewController() -> UIViewController {
        return NZScanCodeViewController(viewModel: self)
    }
}
