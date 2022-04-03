//
//  NZLocationManager.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//  
//  This source code is licensed under The MIT license.
//

import Foundation
import CoreLocation

struct NZLocationData: Encodable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let speed: CLLocationSpeed
    let accuracy: CLLocationAccuracy
    let altitude: CLLocationDistance
    let verticalAccuracy: CLLocationAccuracy
    let horizontalAccuracy: CLLocationAccuracy
}

enum NZLocationType: String, Decodable {
    case wgs84
    case gcj02
}

class NZLocationManager: NSObject {
    
    let locationManager = CLLocationManager()
    
    var getLocationHandler: ((NZLocationData) -> Void)?
    
    var type: NZLocationType = .wgs84
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
    }
    
    func startLocationUpdate(type: NZLocationType, completionHandler: @escaping (NZLocationData) -> Void) {
        self.type = type
        getLocationHandler = completionHandler
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdate() {
        locationManager.stopUpdatingLocation()
    }
}

extension NZLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            var coordinate = location.coordinate
            if type == .gcj02 {
                coordinate = coordinate.gcj02Encrypt()
            }
            let data = NZLocationData(latitude: coordinate.latitude,
                                      longitude: coordinate.longitude,
                                      speed: location.speed,
                                      accuracy: location.horizontalAccuracy,
                                      altitude: location.altitude,
                                      verticalAccuracy: location.verticalAccuracy,
                                      horizontalAccuracy: location.horizontalAccuracy)
            getLocationHandler?(data)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

class NZOnceLocationManager: NSObject {
    
    struct GetLocationParams: Decodable {
        let type: NZLocationType
        let altitude: Bool
        let isHighAccuracy: Bool
        let highAccuracyExpireTime: TimeInterval?
    }
    
    let locationManager = CLLocationManager()
    
    var getLocationHandler: ((NZLocationData?, Error?) -> Void)?
    
    var type: NZLocationType = .wgs84
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func getLocation(params: GetLocationParams, completionHandler: @escaping (NZLocationData?, Error?) -> Void) {
        getLocationHandler = completionHandler
        type = params.type
        if params.isHighAccuracy {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }
        locationManager.requestLocation()
    }
    
}

extension NZOnceLocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            var coordinate = location.coordinate
            if type == .gcj02 {
                coordinate = coordinate.gcj02Encrypt()
            }
            let data = NZLocationData(latitude: coordinate.latitude,
                                      longitude: coordinate.longitude,
                                      speed: location.speed,
                                      accuracy: location.horizontalAccuracy,
                                      altitude: location.altitude,
                                      verticalAccuracy: location.verticalAccuracy,
                                      horizontalAccuracy: location.horizontalAccuracy)
            getLocationHandler?(data, nil)
            getLocationHandler = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        getLocationHandler?(nil, error)
        getLocationHandler = nil
    }
}

extension NZOnceLocationManager {
    
    static let getLocationNotification = Notification.Name("NZOnceLocationManagerGetLocationNotification")
}

extension CLLocationCoordinate2D {
    
    static let A = 6378245.0
    static let EE = 0.00669342162296594323
    
    func gcj02Encrypt() -> CLLocationCoordinate2D {
        if outOfChina() {
            return self
        }
        var dLat = transformLat(latitude: latitude - 35.0, longitude: longitude - 105.0)
        var dLong = transformLong(latitude: latitude - 35.0, longitude: longitude - 105.0)
        let radlat = latitude / 180.0 * Double.pi
        var magic = sin(radlat)
        magic = 1 - CLLocationCoordinate2D.EE * magic * magic
        let sqrtmagic = sqrt(magic)
        dLat = (dLat * 180.0) / ((Self.A * (1 - Self.EE)) / (magic * sqrtmagic) * Double.pi)
        dLong = (dLong * 180.0) / (Self.A / sqrtmagic * cos(radlat) * Double.pi)
        return CLLocationCoordinate2D(latitude: latitude + dLat, longitude: longitude + dLong)
    }
    
    func transformLat(latitude: CLLocationDistance, longitude: CLLocationDistance) -> CLLocationDistance {
        let lat = latitude
        let long = longitude
        var ret = -100.0 + 2.0 * long + 3.0 * lat + 0.2 * lat * lat + 0.1 * long * lat + 0.2 * sqrt(abs(long))
        ret += (20.0 * sin(6.0 * long * Double.pi) + 20.0 * sin(2.0 * long * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(lat * Double.pi) + 40.0 * sin(lat / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (160.0 * sin(lat / 12.0 * Double.pi) + 320 * sin(lat * Double.pi / 30.0)) * 2.0 / 3.0
        return ret
    }
    
    func transformLong(latitude: CLLocationDistance, longitude: CLLocationDistance) -> CLLocationDistance {
        let lat = latitude
        let long = longitude
        var ret = 300.0 + long + 2.0 * lat + 0.1 * long * long + 0.1 * long * lat + 0.1 * sqrt(abs(long))
        ret += (20.0 * sin(6.0 * long * Double.pi) + 20.0 * sin(2.0 * long * Double.pi)) * 2.0 / 3.0
        ret += (20.0 * sin(long * Double.pi) + 40.0 * sin(long / 3.0 * Double.pi)) * 2.0 / 3.0
        ret += (150.0 * sin(long / 12.0 * Double.pi) + 300.0 * sin(long / 30.0 * Double.pi)) * 2.0 / 3.0
        return ret
    }
    
    func outOfChina() -> Bool {
        let lat = latitude
        let long = longitude
        return !(long > 73.66 && long < 135.05 && lat > 3.86 && lat < 53.55)
    }
}
