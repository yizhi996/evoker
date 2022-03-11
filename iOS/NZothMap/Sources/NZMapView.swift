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
        let longitude: Float
        let latitude: Float
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
        let longitude: Float?
        let latitude: Float?
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
        
        addSubview(mapView)
        mapView.autoPinEdgesToSuperviewEdges()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateParams(_ params: UpdateParams) {
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

extension NZMapView: MAMapViewDelegate {
    
}
