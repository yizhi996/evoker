//
//  NZMapView.swift
//
//  Copyright (c) NZoth. All rights reserved. (https://nzothdev.com)
//
//  This source code is licensed under The MIT license.
//

import Foundation
import MAMapKit
import PureLayout

class NZMapView: UIView {
    
    struct Params: Decodable {
        let parentId: String
        let mapId: Int
        let longitude: Double
        let latitude: Double
        let scale: CGFloat
        let minScale: CGFloat
        let maxScale: CGFloat
        let showLocation: Bool
        let showCompass: Bool
        let showScale: Bool
        let enableZoom: Bool
        let enableScroll: Bool
        let enableRotate: Bool
        let enableSatellite: Bool
        let enableTraffic: Bool
        let enableBuilding: Bool
        let enable3D: Bool
    }
    
    struct UpdateParams: Decodable {
        let longitude: Double?
        let latitude: Double?
        let scale: CGFloat?
        let minScale: CGFloat?
        let maxScale: CGFloat?
        let showLocation: Bool?
        let showCompass: Bool?
        let showScale: Bool?
        let enableZoom: Bool?
        let enableScroll: Bool?
        let enableRotate: Bool?
        let enableSatellite: Bool?
        let enableTraffic: Bool?
        let enableBuilding: Bool?
        let enable3D: Bool?
    }
    
    let params: Params
    let mapView = MAMapView(frame: .zero)
    
    var mapId: Int {
        return params.mapId
    }
    
    weak var delegate: NZMapViewDelegate?
    
    init(params: Params) {
        self.params = params
        super.init(frame: .zero)
        
        MAMapView.updatePrivacyShow(.didShow, privacyInfo: .didContain)
        MAMapView.updatePrivacyAgree(.didAgree)
        
        mapView.delegate = self
        mapView.userTrackingMode = .follow
        let representation = MAUserLocationRepresentation()
        representation.showsHeadingIndicator = true
        mapView.update(representation)
        
        mapView.showsUserLocation = params.showLocation
        mapView.showsCompass = params.showCompass
        mapView.showsScale = params.showScale
        mapView.isZoomEnabled = params.enableZoom
        mapView.isScrollEnabled = params.enableScroll
        mapView.isRotateEnabled = params.enableRotate
        mapView.mapType = params.enableSatellite ? .satellite : .standard
        mapView.maxZoomLevel = params.maxScale
        mapView.minZoomLevel = params.minScale
        mapView.zoomLevel = params.scale
        mapView.isShowTraffic = params.enableTraffic
        mapView.isShowsBuildings = params.enable3D
        
        mapView.setCenter(CLLocationCoordinate2D(latitude: params.latitude, longitude: params.longitude), animated: false)
        
        addSubview(mapView)
        mapView.autoPinEdgesToSuperviewEdges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateParams(_ params: UpdateParams) {
        if let longitude = params.longitude, let latitude = params.latitude {
            mapView.setCenter(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), animated: false)
        }
        if let showLocation = params.showLocation {
            mapView.showsUserLocation = showLocation
        }
        if let showCompass = params.showCompass {
            mapView.showsCompass = showCompass
        }
        if let showSclae = params.showScale {
            mapView.showsScale = showSclae
        }
        if let enableZoom = params.enableZoom {
            mapView.isZoomEnabled = enableZoom
        }
        if let enableScroll = params.enableScroll {
            mapView.isScrollEnabled = enableScroll
        }
        if let enableRotate = params.enableRotate {
            mapView.isRotateEnabled = enableRotate
        }
        if let enableSatellite = params.enableSatellite {
            mapView.mapType = enableSatellite ? .satellite : .standard
        }
        if let maxScale = params.maxScale {
            mapView.maxZoomLevel = maxScale
        }
        if let minScale = params.minScale {
            mapView.minZoomLevel = minScale
        }
        if let scale = params.scale {
            mapView.zoomLevel = scale
        }
        if let scale = params.scale {
            mapView.zoomLevel = scale
        }
        if let enableTraffic = params.enableTraffic {
            mapView.isShowTraffic = enableTraffic
        }
        if let enable3D = params.enable3D {
            mapView.isShowsBuildings = enable3D
        }
    }
    
}

extension NZWebView: NZMapViewDelegate {
    
    func mapView(_ mapView: NZMapView, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        bridge.subscribeHandler(method: NZMapView.onTapSubscribeKey,
                                        data: ["mapId": mapView.mapId,
                                               "longitude": coordinate.longitude,
                                               "latitude": coordinate.latitude])
    }
    
    func mapView(_ mapView: NZMapView, regionWillChangeAnimated animated: Bool, wasUserAction: Bool) {
        bridge.subscribeHandler(method: NZMapView.onRegionChangeSubscribeKey,
                                        data: ["mapId": mapView.mapId,
                                               "type": "begin"])
    }
    
    func mapView(_ mapView: NZMapView, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        let center = mapView.mapView.centerCoordinate
        bridge.subscribeHandler(method: NZMapView.onRegionChangeSubscribeKey,
                                        data: ["mapId": mapView.mapId,
                                               "type": "end",
                                               "centerLocation": ["longitude": center.longitude,
                                                                  "latotude": center.latitude]])
    }
    
    func mapInitComplete(_ mapView: NZMapView) {
        bridge.subscribeHandler(method: NZMapView.onUpdatedSubscribeKey, data: ["mapId": mapView.mapId])
    }
    
    func mapView(_ mapView: NZMapView, didTouchPoi poi: MATouchPoi) {
        bridge.subscribeHandler(method: NZMapView.onTapPoiSubscribeKey,
                                        data: ["mapId": mapView.mapId,
                                               "name": poi.name!,
                                               "longitude": poi.coordinate.longitude,
                                               "latitude": poi.coordinate.latitude])
    }
    
}

extension NZMapView: MAMapViewDelegate {
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        delegate?.mapView(self, didSingleTappedAt: coordinate)
    }
    
    func mapView(_ mapView: MAMapView!, regionWillChangeAnimated animated: Bool, wasUserAction: Bool) {
        delegate?.mapView(self, regionWillChangeAnimated: animated, wasUserAction: wasUserAction)
    }
    
    func mapView(_ mapView: MAMapView!, regionDidChangeAnimated animated: Bool, wasUserAction: Bool) {
        delegate?.mapView(self, regionDidChangeAnimated: animated, wasUserAction: wasUserAction)
    }
    
    func mapInitComplete(_ mapView: MAMapView!) {
        delegate?.mapInitComplete(self)
    }
    
    func mapView(_ mapView: MAMapView!, didTouchPois pois: [Any]!) {
        guard let pois = pois as? [MATouchPoi], let poi = pois.first else { return }
        delegate?.mapView(self, didTouchPoi: poi)
    }
    
}

protocol NZMapViewDelegate: NSObject {
    
    func mapView(_ mapView: NZMapView, didSingleTappedAt coordinate: CLLocationCoordinate2D)
    
    func mapView(_ mapView: NZMapView, regionWillChangeAnimated animated: Bool, wasUserAction: Bool)
    
    func mapView(_ mapView: NZMapView, regionDidChangeAnimated animated: Bool, wasUserAction: Bool)
    
    func mapInitComplete(_ mapView: NZMapView)
    
    func mapView(_ mapView: NZMapView, didTouchPoi poi: MATouchPoi)
}

extension NZMapView {
    
    public static let onUpdatedSubscribeKey = NZSubscribeKey("MODULE_MAP_ON_UPDATED")
    
    public static let onTapSubscribeKey = NZSubscribeKey("MODULE_MAP_ON_TAP")
    
    public static let onTapPoiSubscribeKey = NZSubscribeKey("MODULE_MAP_ON_TAP_POI")
    
    public static let onRegionChangeSubscribeKey = NZSubscribeKey("MODULE_MAP_ON_REGION_CHANGE")
    
}
