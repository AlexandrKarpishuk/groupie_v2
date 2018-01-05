//
//  ViewController.swift
//  groupie
//
//  Created by Xinran on 3/26/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit
import FontAwesome_swift
import GoogleMaps


class ViewController: GroupieViewController {
    
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate let locationManager = CLLocationManager()
    fileprivate let fbPermissions = ["public_profile", "email", "user_friends"]
    
    @IBOutlet weak var mapView: GMSMapView?
    @IBOutlet weak var fbLoginButton: UIButton?
    @IBOutlet weak var fbLogoutButton: UIButton?
    @IBOutlet weak var addressLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        if let mapView = mapView{
            self.view.addSubview(mapView)
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        mapView?.delegate = self
        
//        mapView?.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
//        self.title = String.fontAwesomeIconWithName(FontAwesome.ListUL)
        self.title = String.fontAwesomeIcon(name: FontAwesome.map)
    }
    
    @IBAction func loginButtonClicked(_ sender: AnyObject?){
        let successBlock = { (json: AnyObject) -> () in
            NSLog("Successfully logged in fb user")
            let id = json["id"]
            let email = json["email"]
            let token = json["token"]
            self.defaults.set(id, forKey: "id")
            self.defaults.set(email, forKey: "email")
            self.defaults.set(token, forKey: "token")
        }
        let failureBlock = { (error: NSError?) -> () in
            NSLog("Failed to login fb user with error \(error)")
        }
        loginToFacebookWithSuccess(successBlock, andFailure: failureBlock)
    }
    
    @IBAction func logoutButtonClicked(_ sender: AnyObject?){
        FBSDKLoginManager().logOut()
        self.defaults.removeObject(forKey: "id")
        self.defaults.removeObject(forKey: "email")
        self.defaults.removeObject(forKey: "token")
    }
    
    fileprivate func loginToFacebookWithSuccess(_ successBlock: @escaping (AnyObject) -> (), andFailure failureBlock: @escaping (NSError?) -> ()){
        
        if FBSDKAccessToken.current() != nil {
            if Constants.loginDebug {
                FBSDKLoginManager().logOut()
            } else {
                return
            }
        }
        
        FBSDKLoginManager().logIn(withReadPermissions: fbPermissions, from: self, handler: { (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            
            if (error != nil) {
                NSLog("Error logging in. \(error)")
                FBSDKLoginManager().logOut()
                failureBlock(error)
                return
            } else if (result.isCancelled) {
                FBSDKLoginManager().logOut()
                failureBlock(nil)
                return
            }
            
            if !self.hasPermissions(result.grantedPermissions as! Set<NSObject>) {
                //The user did not grant all permissions requested
                //Discover which permissions are granted
                //and if you can live without the declined ones
                failureBlock(nil)
            }
            
            
            let fbToken = result.token.tokenString
            let fbUserID = result.token.userID
            
            self.loginUserWithToken(fbToken!, successBlock: successBlock, andFailure: failureBlock)
        } as! FBSDKLoginManagerRequestTokenHandler)
    }
    
    fileprivate func loginUserWithToken(_ token: String, successBlock: @escaping (AnyObject) -> (), andFailure failureBlock: (NSError?) -> ()){
        Alamofire.request(Constants.API.FbAuth, method: HTTPMethod.get, parameters: ["access_token": token], encoding: JSONEncoding.default) //.request(.GET, Constants.API.FbAuth, parameters: ["access_token": token])
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let resp = response.result.value {
                        successBlock(resp as AnyObject)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    fileprivate func hasPermissions(_ grantedPermissions: Set<NSObject>) -> Bool {
        // check if all permissions were granted
        var allPermsGranted = true
        let grantedPermissions = grantedPermissions.map( {"\($0)"} )
        for permission in self.fbPermissions {
            if !grantedPermissions.contains(permission){
                allPermsGranted = false
                break
            }
        }
        
        return allPermsGranted
    }
}

extension ViewController: CLLocationManagerDelegate{
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

extension ViewController: GMSMapViewDelegate{
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        addressLabel?.lock()
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(position.target)
    }
    
    fileprivate func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            self.addressLabel?.unlock()
            
            if let address = response?.firstResult() {
                
                self.addressLabel?.text = address.lines?.joined(separator: "\n")
                
                UIView.animate(withDuration: 0.25, animations: {
                    self.view.layoutIfNeeded()
                }) 
            }
        }
    }
}
