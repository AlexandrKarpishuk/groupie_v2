//
//  Constants.swift
//  groupie
//
//  Created by Xinran on 3/27/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    static let debug: Bool = true
    static let loginDebug: Bool = false
    
    struct API {
//        static let Root = "http://localhost:8000/"
//        static let Root = "http://groupieServer-dev2.us-west-2.elasticbeanstalk.com/"
        static let Root = "http://groupieServer-stage.us-east-1.elasticbeanstalk.com/"
        static let API = Root + "api/"
        static let AuthRoot = Root + "rest-auth/"
        
        static let Registration = AuthRoot + "registration/"
        static let Login = AuthRoot + "login/"
        static let User = AuthRoot + "user/"
        static let FbAuth = API + "register-by-token/facebook/"
        static let Workouts = API + "workouts/"
    }
    
    struct Storyboards{
        static let Main = UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    struct Cells{
        static let WorkoutListCell = "workoutListCell"
    }
    
    struct Notifications{
        static let WorkoutsUpdated = "WorkoutsUpdatedNotification"
        
    }
}
