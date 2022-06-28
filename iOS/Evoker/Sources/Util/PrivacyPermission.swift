//
//  PrivacyPermission.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import AVFoundation
import CoreBluetooth
import Photos

class PrivacyPermission {
    
    enum Status: Int {
        case authorized
        case denied
        case notDetermined
        
        func toString() -> String {
            switch self {
            case .authorized:
                return "authorized"
            case .denied:
                return "denied"
            case .notDetermined:
                return "not determined"
            }
        }
    }
    
    static let shared = PrivacyPermission()
    
    var bluetoothHandler: BluetoothHandler?
    
    var locationHandler: LocationHandler?
    
}

//MARK: Album {
extension PrivacyPermission {
    
    class var album: Status {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return .authorized
        case .denied:
        return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .denied
        case .limited:
            return .authorized
        @unknown default:
            return .denied
        }
    }
    
    class func requestAlbum(completion: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization({ finished in
            DispatchQueue.main.async {
                completion()
            }
        })
    }
}

//MARK: Location
extension PrivacyPermission {
    
    class var location: Status {
        let locationManager = CLLocationManager()
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = locationManager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .denied
        case .authorizedAlways:
            return .authorized
        case .authorizedWhenInUse:
            return .authorized
        @unknown default:
            return .denied
        }
    }
    
    class var isLocationReduced: Bool {
        if #available(iOS 14.0, *) {
            switch CLLocationManager().accuracyAuthorization {
            case .fullAccuracy:
                return false
            case .reducedAccuracy:
                return true
            @unknown default:
                return false
            }
        }
        return false
    }
    
    class func requestLocation(completion: @escaping () -> Void) {
        let handler = LocationHandler()
        handler.completionHandler = {
            shared.locationHandler = nil
            completion()
        }
        shared.locationHandler = handler
    }
}

//MARK: Camera
extension PrivacyPermission {
    
    class var camera: Status {
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
    
    class var microphone: Status {
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
    
    class var bluetooth: Status {
        if #available(iOS 13.1, *) {
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
        } else if #available(iOS 13.0, *) {
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
        let handler = BluetoothHandler()
        handler.completionHandler = {
            completion()
            shared.bluetoothHandler = nil
        }
        shared.bluetoothHandler = BluetoothHandler()
    }
}

//MARK: Notification
extension PrivacyPermission {
    
    struct NotificationSettings {
        let status: Status
        let alert: Status
        let badge: Status
        let sound: Status
    }
    
    class var notificationSettings: NotificationSettings {
        let center = UNUserNotificationCenter.current()
        
        let semaphore = DispatchSemaphore(value: 0)
        var settings: UNNotificationSettings?
        DispatchQueue.global().async {
            center.getNotificationSettings { _settings in
                settings = _settings
                semaphore.signal()
            }
        }
        semaphore.wait()
        let notDetermined = NotificationSettings(status: .notDetermined,
                                                 alert: .notDetermined,
                                                 badge: .notDetermined,
                                                 sound: .notDetermined)
        let denied = NotificationSettings(status: .denied,
                                          alert: .denied,
                                          badge: .denied,
                                          sound: .denied)
        guard let settings = settings else { return notDetermined }
        
        let authorized = NotificationSettings(status: .authorized,
                                              alert: settings.alertSetting == .enabled ? .authorized : .denied,
                                              badge: settings.badgeSetting == .enabled ? .authorized : .denied,
                                              sound: settings.soundSetting == .enabled ? .authorized : .denied)
        
        switch settings.authorizationStatus {
        case .authorized:
            return authorized
        case .denied:
            return denied
        case .notDetermined:
            return notDetermined
        case .provisional:
            return authorized
        case .ephemeral:
            return authorized
        @unknown default:
            return denied
        }
    }
    
    class func requestNotification(completion: @escaping () -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { _,_  in
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
}

class BluetoothHandler: NSObject {
    
    var completionHandler: EmptyBlock?
        
    var manager: CBCentralManager?
    
    override init() {
        super.init()
        
        manager = CBCentralManager(delegate: self, queue: nil, options: [:])
    }
    
}

extension BluetoothHandler: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        completionHandler?()
    }

}

class LocationHandler: NSObject {
    
    var completionHandler: EmptyBlock?
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
}

extension LocationHandler: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        completionHandler?()
    }

}
