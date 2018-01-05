//
//  LikesManager.swift
//  groupie
//
//  Created by Sania on 8/15/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class LikesManager {
    
    static var shared = LikesManager()
    
    static let ON_LIKED_NOTIFICATION = Notification.Name("LikesReadedNotification")
    
    fileprivate var likedWorkouts = Set<Int64>()
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLoggedIN),
                                               name: ServerManager.LOGGED_IN_NOTIFICATION,
                                               object: nil)
    }
    
    
    @objc func onLoggedIN(_ notify: Notification) {
        ServerManager.shared.GetMyLikes(onSuccess: { (likes:Set<Int64>) in
            self.likedWorkouts = likes
            
            DBService.shared.PerformBlockInDBQueue {
                DBService.shared.RemoveAllObjectsOfClass(MyLikeEntity.self)
                let info = NSMutableArray()
                for workID in likes {
                    info.add(["workoutID": workID])
                }
                let _ = DBService.shared.CreateObjectsFromCurrentThread(MyLikeEntity.self, infoArray: info)
            }
            
            NotificationCenter.default.post(name: LikesManager.ON_LIKED_NOTIFICATION, object: nil)
        }, onFail:  { (message:String?) in
            NSLog("\(message)")
        })
    }
    
    func isLiked(workout: WorkoutInfo?, completed:((Bool)->Void)? = nil) -> Bool {
        if (workout != nil) {
            if (self.likedWorkouts.contains(workout!.id)) {
                return true
            }
            if (completed != nil) {
                DBService.shared.AllObjectsOfClass(MyLikeEntity.self,
                                               filter: "workoutID=\(workout!.id)", completed: { (result: NSArray?) in
                                                if (result != nil) {
                                                    self.likedWorkouts.insert(workout!.id)
                                                    completed?(result!.count > 0)
                                                } else {
                                                    completed?(false)
                                                }
                })
            }
        }
        return false
    }
    
    func like(workout: WorkoutInfo,
              onSuccess:((_ workout: WorkoutInfo, _ likesCount:Int64)->Void)?,
              onFail:((_ message: String?)->Void)? ){
        ServerManager.shared.Like(workoutID: workout.id, onSuccess: { (workID:Int64, likes:Int64) in
            workout.likes = UInt(likes)
            
            self.likedWorkouts.insert(workID)
            
            onSuccess?(workout, likes)
        }, onFail: { (message:String?) in
            onFail?(message)
        })
        
    }
    
    func dislike(workout: WorkoutInfo,
              onSuccess:((_ workout: WorkoutInfo, _ likesCount:Int64)->Void)?,
              onFail:((_ message: String?)->Void)? ){
        ServerManager.shared.Dislike(workoutID: workout.id, onSuccess: { (workID:Int64, likes:Int64) in
            workout.likes = UInt(likes)
            
            self.likedWorkouts.remove(workID)
            
            onSuccess?(workout, likes)
        }, onFail: { (message:String?) in
            onFail?(message)
        })
        
    }
}
