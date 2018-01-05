//
//  DataManager.swift
//  groupie
//
//  Created by Xinran on 4/23/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import FBSDKCoreKit


class DataManager{
    static let sharedInstance = DataManager()
    
    var workouts: [Workout] = [Workout]()
    
    fileprivate func setNewWorkouts(_ newWorkouts: [Workout]){
        if newWorkouts.count == 0 {
            workouts = [Workout]()
        } else {
            self.workouts = newWorkouts
        }
        
        NSLog("setting new workouts")
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constants.Notifications.WorkoutsUpdated), object: self, userInfo: ["workouts": workouts])
    }
    
    func fetchWorkouts(_ completion: (([Workout]?) -> ())?){
        return
        var headers = [String: String]()
     //   let defaults = UserDefaults.standard
        let token = FBSDKAccessToken.current().tokenString // defaults.object(forKey: "token") as! String
        headers["Authorization"] = "Token \(token!)"
        
    //    Alamofire.request(.GET, Constants.API.Workouts, headers: headers, encoding: .JSON)
        
        Alamofire.request( Constants.API.Workouts,
                           method: HTTPMethod.get,
                           encoding: JSONEncoding.default,
                           headers: headers)
            .validate()
            .responseJSON { response in                
                guard response.result.isSuccess else {
                    NSLog("Error while fetching workouts: \(response.result.error) Request: \(request) Response: \(response)")
                    completion?(nil)
                    return
                }

                guard let json = response.result.value as? [AnyObject] else {
                        NSLog("Malformed data received from fetchWorkouts service")
                        completion?(nil)
                        return
                }

                var newWorkouts = [Workout]()
                for workout in json {
                    newWorkouts.append(Workout(name: workout["name"] as! String))
                }
                self.setNewWorkouts(newWorkouts)
                
                NSLog("Successfully fetched \(newWorkouts.count) workouts")
                
                completion?(self.workouts)
        }
    }
}
