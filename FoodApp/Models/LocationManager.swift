//
//  LocationManager.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    var locationManager: CLLocationManager
    var isAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse
    }
    
    var currentLocation: CLLocation? {
        locationManager.location
    }
    
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.desiredAccuracy =  kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        NotificationCenter.default.post(name: .init(rawValue: "locationAuthChanged"), object: nil)
        switch manager.authorizationStatus {
            
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
}
