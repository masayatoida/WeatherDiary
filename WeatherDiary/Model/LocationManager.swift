//
//  LocationManager.swift
//  WeatherDiary
//
//  Created by 戸井田莉江 on 2022/04/05.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var latitudeNow = ""
    var longitudeNow = ""
    
    func isPermission() -> Bool {
        let manager = CLLocationManager()
        return manager.authorizationStatus == .denied ? false : true
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        let manager = CLLocationManager()
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        guard let latitude = location?.coordinate.latitude,
              let longitude = location?.coordinate.longitude else { return }
        self.latitudeNow = String(latitude)
        self.longitudeNow = String(longitude)
    }
}
