//
//  PrivacyPermission.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation
import CoreBluetooth

class PrivacyPermission {
    
    enum PermissionStatus: Int {
        case authorized
        case denied
        case notDetermined
    }
    
}

//MARK: Camera
extension PrivacyPermission {
    
    class var camera: PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
    
    class func requestCamera(completion: @escaping () -> Void) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { finished in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}

//MARK: Microphone
extension PrivacyPermission {
    
    class var microphone: PermissionStatus {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            return .authorized
        case .denied:
            return .denied
        case .undetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
    
    class func requestMicrophone(completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission {
            granted in
            DispatchQueue.main.async {
                completion()
            }
        }
    }
}

//MARK: Bluetooth
extension PrivacyPermission {
    
    class var bluetooth: PermissionStatus {
        if #available(iOS 13.1, tvOS 13.1, *) {
            switch CBCentralManager.authorization {
            case .allowedAlways:
                return .authorized
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .denied
            case .denied:
                return .denied
            default:
                return .denied
            }
        } else if #available(iOS 13.0, tvOS 13.0, *) {
            switch CBCentralManager().authorization {
            case .allowedAlways:
                return .authorized
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .denied
            case .denied:
                return .denied
            default:
                return .denied
            }
        } else {
            switch CBPeripheralManager.authorizationStatus() {
            case .authorized:
                return .authorized
            case .denied:
                return .denied
            case .restricted:
                return .denied
            case .notDetermined:
                return .notDetermined
            default:
                return .denied
            }
        }
    }

    class func requestBluetooth(completion: @escaping () -> Void) {
        NZBluetoothManager.shared.completion = completion
        NZBluetoothManager.shared.requestAuthorization()
    }
}

class NZBluetoothManager: NSObject {
    
    var completion: NZEmptyBlock?
        
    static let shared = NZBluetoothManager()
    
    var manager: CBCentralManager?
    
    override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [:])
    }
    
    func requestAuthorization() {
        completion?()
    }
}

extension NZBluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if #available(iOS 13.0, tvOS 13, *) {
            switch central.authorization {
            case .notDetermined:
                break
            default:
                completion?()
            }
        } else {
            switch CBPeripheralManager.authorizationStatus() {
            case .notDetermined:
                break
            default:
                completion?()
            }
        }
    }

}
