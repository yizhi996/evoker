//
//  LocationManager.swift
//
//  Copyright (c) Evoker. All rights reserved. (https://evokerdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import CoreLocation

struct LocationData: Encodable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let speed: CLLocationSpeed
    let accuracy: CLLocationAccuracy
    let altitude: CLLocationDistance
    let verticalAccuracy: CLLocationAccuracy
    let horizontalAccuracy: CLLocationAccuracy
}

enum LocationType: String, Decodable {
    case wgs84
    case gcj02
}

class LocationManager: NSObject {
    
    let locationManager = CLLocationManager()
    
    var getLocationHandler: ((LocationData?, EKError?) -> Void)?
    
    var type: LocationType = .wgs84
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
    }
    
    func startLocationUpdate(type: LocationType, completionHandler: @escaping (LocationData?, EKError?) -> Void) {
        self.type = type
        getLocationHandler = completionHandler
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getLocationHandler?(location.toData(type: type), nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        getLocationHandler?(nil, EKError.custom(error.localizedDescription))
    }

}

class OnceLocationManager: NSObject {
    
    struct GetLocationParams: Decodable {
        let type: LocationType
        let altitude: Bool
        let isHighAccuracy: Bool
        let highAccuracyExpireTime: TimeInterval?
    }
    
    let locationManager = CLLocationManager()
    
    var getLocationHandler: ((LocationData?, Error?) -> Void)?
    
    var type: LocationType = .wgs84
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(params: GetLocationParams, completionHandler: @escaping (LocationData?, Error?) -> Void) {
        locationManager.stopUpdatingLocation()
        if let getLocationHandler = getLocationHandler {
            getLocationHandler(nil, EKError.custom("stop"))
        }
        
        getLocationHandler = completionHandler
        type = params.type
        if params.isHighAccuracy {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            if let highAccuracyExpireTime = params.highAccuracyExpireTime {
                DispatchQueue.main.asyncAfter(deadline: .now() + highAccuracyExpireTime / 1000) {
                    self.locationManager.stopUpdatingLocation()
                    if let location = self.locationManager.location {
                        self.getLocationHandler?(location.toData(type: self.type), nil)
                    } else {
                        self.getLocationHandler?(nil, EKError.custom("not location"))
                    }
                    self.getLocationHandler = nil
                }
            }
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        locationManager.requestLocation()
    }
    
    
}

extension OnceLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            getLocationHandler?(location.toData(type: type), nil)
            getLocationHandler = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        getLocationHandler?(nil, error)
        getLocationHandler = nil
    }
}

extension OnceLocationManager {
    
    static let getLocationNotification = Notification.Name("OnceLocationManagerGetLocationNotification")
}
