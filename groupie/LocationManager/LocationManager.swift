//
//  LocationManager.swift
//  groupie
//
//  Created by Sania on 7/29/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject {
    
    public static let shared = LocationManager()
    
    static let LOCATION_UPDATED_NOTIFICATION = "LocationManager_LocationUpdated"
    
    fileprivate(set) var currentLocationLatitude: Double = 0
    fileprivate(set) var currentLocationLongitude: Double = 0
    fileprivate(set) var currentLocation: String = ""
    
    fileprivate var locationManager = CLLocationManager()
    fileprivate var geocoder = CLGeocoder()
    
    override init() {
        super.init()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
 //       self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.delegate = self
        
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationManager : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            self.currentLocationLatitude = locations[0].coordinate.latitude
            self.currentLocationLongitude = locations[0].coordinate.longitude
            
            self.geocoder.reverseGeocodeLocation(locations[0], completionHandler: { (placemarks:[CLPlacemark]?, error: Error?) in
                if (error != nil) {
                    NSLog("Fail to get address")
                    self.currentLocation = ""
                } else {
                    if (placemarks != nil && placemarks!.count > 0) {
                        let place = placemarks![0]
                        var placeStr = ""
                        if (place.country != nil) {
                            placeStr += place.country!
                        }
                        if (place.locality != nil) {
                            if (placeStr.isEmpty == false) {placeStr += ", "}
                            placeStr += place.locality!
                        }
                        if (place.name != nil) {
                            if (placeStr.isEmpty == false) {placeStr += ", "}
                            placeStr += place.name!
                        }
                        self.currentLocation = placeStr
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: LocationManager.LOCATION_UPDATED_NOTIFICATION), object: nil)
                    } else {
                        self.currentLocation = ""
                    }
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location Manager failed! Error: \(error)")
    }
    
}
