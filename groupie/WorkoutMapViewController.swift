//
//  WorkoutMapViewController.swift
//  groupie
//
//  Created by Xinran on 4/24/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import FontAwesome_swift
import GoogleMaps


class WorkoutMapViewController: UIViewController{
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate var workoutMarkers = [GMSMarker]()
    
    @IBOutlet weak var mapView: GMSMapView?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        mapView?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateWorkouts), name: NSNotification.Name(rawValue: Constants.Notifications.WorkoutsUpdated), object: nil)
        
        self.moveCurrentLocationButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()
    }
    
    fileprivate func moveCurrentLocationButton(){
//        if let button = mapView?.subviews.last as? UIButton{
//            button.autoresizingMask = [.FlexibleRightMargin, .FlexibleTopMargin]
//            var frame = button.frame
//            frame.origin.x = 5
//            button.frame = frame
//        }
    }
    
    @objc fileprivate func updateWorkouts(){
        for workout in DataManager.sharedInstance.workouts{
            addWorkoutMarker(workout)
        }
    }
    
    fileprivate func clearWorkouts(){
        mapView?.clear()
        workoutMarkers.removeAll(keepingCapacity: false)
    }
    
    fileprivate func addWorkoutMarker(_ workout: Workout){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(40.757651, -73.981891)
        marker.title = workout.name
        marker.snippet = workout.name
        marker.map = mapView
        
        workoutMarkers.append(marker)
    }
}

extension WorkoutMapViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
            mapView?.settings.indoorPicker = true
            mapView?.settings.scrollGestures = true
            mapView?.settings.zoomGestures = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            mapView?.camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 10.0)
            locationManager.stopUpdatingLocation()
        }
    }
    
    //    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    //        let myLocation: CLLocation = change![NSKeyValueChangeNewKey] as! CLLocation
    //        mapView?.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
    //    }
}

extension WorkoutMapViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    fileprivate func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if let address = response?.firstResult() {
//                address.lines?.joinWithSeparator("\n")
//                self.log.debug("address: \(address)")
            }
        }
    }
}
