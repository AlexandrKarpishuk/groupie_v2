//
//  WorkoutsManager.swift
//  groupie
//
//  Created by Sania on 7/29/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import Contacts
import CoreData

class WorkoutsManager {
    
    static let shared = WorkoutsManager()
    fileprivate(set) var workoutsAll = [WorkoutInfo]()
    fileprivate(set) var workoutsPublic = [WorkoutInfo]()
    fileprivate(set) var workoutsPersonal = [WorkoutInfo]()
    fileprivate(set) var workoutsFriends = [WorkoutInfo]()
    
    static let WORKOUT_DID_POST_NOTIFICATION = Notification.Name("Workout_DidPost")
    static let WORKOUT_COMMENTS_UPDATED = Notification.Name("Workout_CommentsUpdated")
    static let WORKOUT_LIKES_UPDATED = Notification.Name("Workout_LikesUpdated")
    static let WORKOUT_DB_READED = Notification.Name("Workout_DB_Readed")
    static let WORKOUTS_DID_UPDATED = Notification.Name("WorkoutsDidUpdated")
    static let INFO_UNCHANGED = "unchanged"
    static let INFO_UPDATED = "updated"
    static let INFO_NEW = "new"
    static let INFO_UNUSED = "unused"
    
    fileprivate var p_updatingTime: Int = 0
    fileprivate var p_isLoadedFromDB: Bool = false
    fileprivate var p_isWorkoutsLoadingInProgress = false
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OnContactsUpdated(notify:)),
                                               name: ContactsManager.CONTACTS_LOADED_NOTIFICATION,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OnDBOpened(notify:)),
                                               name: DBService.IS_OPENED_NOTIFICATION,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reset), name: ServerManager.LOGGED_OUT_NOTIFICATION,
                                               object: nil)
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onUpdateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func onUpdateTimer() {
        if (ServerManager.shared.isLoggedIn && !self.p_isWorkoutsLoadingInProgress) {
            self.p_updatingTime += 1
            if (self.p_updatingTime >= 15) {
                self.UpdateWorkoutsPublic()
            }
            if (self.p_updatingTime == 5) {
                FriendsManager.shared.UpdateFollow()
            }
            if (self.p_updatingTime == 10) {
                FriendsManager.shared.UpdateFollowing()
            }
        }
    }
    
    func loadFromCoreData() {
        DBService.shared.AllObjectsOfClass(WorkoutEntity.self) { (workouts:NSArray?) in
            self.p_isLoadedFromDB = true
            if (workouts != nil) {
                var newPublic = [WorkoutInfo]()
                for entity in workouts! {
                    let newWorkout = WorkoutInfo(info:[:])
                    newWorkout.fromEntity(entity as? WorkoutEntity)
                    newPublic.append(newWorkout)
                }
                self.workoutsAll = newPublic.sorted(by: { (info1:WorkoutInfo, info2:WorkoutInfo) -> Bool in
                    return info1.modified_time_original > info2.modified_time_original
                })
                self.workoutsPublic = self.workoutsAll.filter({ (info:WorkoutInfo) -> Bool in
                    return info.isPublic && info.is_active
                })

                self.filterWorkouts()
                NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_DB_READED, object: nil)
            }
            self.p_updatingTime = 60
            self.UpdateWorkoutsPublic()
        }
    }
    
    @objc func reset() {
        self.workoutsPublic = [WorkoutInfo]()
        self.workoutsFriends = [WorkoutInfo]()
        self.workoutsPersonal = [WorkoutInfo]()
        self.p_isLoadedFromDB = false
    }
    

//MARK: - Workouts
    func UpdateWorkoutsPublic() {
        if (ServerManager.shared.isLoggedIn) {
            if (self.p_updatingTime < 15) {
                self.p_updatingTime += 11
            }
            if (self.p_updatingTime >= 15 && self.p_isLoadedFromDB && !self.p_isWorkoutsLoadingInProgress) {
                self.p_isWorkoutsLoadingInProgress = true
                self.p_updatingTime = 0
                
                var lastModified: String? = nil
                if (self.workoutsAll.count > 0) {
                    lastModified = self.workoutsAll[0].modified_time_original
                }
                ServerManager.shared.GetWorkoutsPublic(lastModified: lastModified,
                                                       onSuccess: { (workouts:[WorkoutInfo]) in
                #if DEBUG
                    let mergeStartTime = Date()
                #endif
                    self.mergeWorkouts(workouts, completed: { (unchanged:[WorkoutInfo], updated:[WorkoutInfo], new:[WorkoutInfo], unused:[WorkoutInfo]) in
                        
                        var newWorkouts = [WorkoutInfo]()
                        
               /*         newWorkouts.append(contentsOf: unchanged)
                        newWorkouts.append(contentsOf: updated)*/
                        newWorkouts.append(contentsOf: new)
                        newWorkouts.append(contentsOf: self.workoutsAll)
                        
                        self.workoutsAll = newWorkouts
                        
                        newWorkouts = newWorkouts.filter({ (info:WorkoutInfo) -> Bool in
                            return info.isPublic && info.is_active
                        })
                        
                        self.workoutsPublic = newWorkouts.sorted(by: { (info1:WorkoutInfo, info2:WorkoutInfo) -> Bool in
                            return info1.modified_time_original > info2.modified_time_original
                        })
                        
                        self.filterWorkouts()
                        
                        let info = [WorkoutsManager.INFO_UNCHANGED: unchanged,
                                    WorkoutsManager.INFO_UPDATED: updated,
                                    WorkoutsManager.INFO_NEW: new,
                                    WorkoutsManager.INFO_UNUSED: unused]
                        NotificationCenter.default.post(name: WorkoutsManager.WORKOUTS_DID_UPDATED, object: nil, userInfo: info)
                    #if DEBUG
                        let mergeEndTime = Date()
                        NSLog("Workouts merge Time: \(mergeEndTime.timeIntervalSince(mergeStartTime)) sec")
                    #endif
                        self.p_isWorkoutsLoadingInProgress = false
                    })
                }) { (message: String?) in
                    NSLog("Message: \(String(describing: message))")
                    self.p_isWorkoutsLoadingInProgress = false
                }
            }
        }
    }
    
    func UpdateWorkoutsPersonal(completed: ((_ unchanged:[WorkoutInfo], _ updated:[WorkoutInfo], _ new:[WorkoutInfo], _ unused:[WorkoutInfo])->Void)?) {
        ServerManager.shared.GetWorkoutsPersonal(userNick: "", onSuccess: { (workouts: [WorkoutInfo]) in
            self.mergeWorkouts(workouts, completed: { (unchanged:[WorkoutInfo], updated:[WorkoutInfo], new:[WorkoutInfo], unused:[WorkoutInfo]) in

                
                
                if (completed != nil) {
                    completed!(unchanged, updated, new, unused)
                }
            })
        }) { (message: String?) in
            NSLog("Message: \(String(describing: message))")
        }
    }
    
    func UpdateWorkoutsFriends(completed: ((_ unchanged:[WorkoutInfo], _ updated:[WorkoutInfo], _ new:[WorkoutInfo], _ unused:[WorkoutInfo])->Void)?) {
        ServerManager.shared.GetWorkoutsFriends(onSuccess: { (workouts: [WorkoutInfo]) in
            self.mergeWorkouts(workouts, completed: { (unchanged:[WorkoutInfo], updated:[WorkoutInfo], new:[WorkoutInfo], unused:[WorkoutInfo]) in
                if (completed != nil) {
                    completed!(unchanged, updated, new, unused)
                }
            })
        }) { (message: String?) in
            NSLog("Message: \(String(describing: message))")
        }
    }
    
    func PostWorkout(name: String, descr: String, type: String, isPublic: Bool, onSuccess: ((WorkoutInfo)->Void)?, onFail:((String?)->Void)?) {
        self.p_updatingTime -= 5
        ServerManager.shared.PostWorkout(workoutName: name,
                                         workoutDescription: descr,
                                         workoutType: type,
                                         isPublic: isPublic,
                                         onSuccess: { (workout: WorkoutInfo) in
            self.workoutsAll.insert(workout, at: 0)
            if (workout.isPublic && workout.is_active) {
                self.workoutsPublic.insert(workout, at: 0)
            }
            self.filterWorkouts()
            if (onSuccess != nil) {
                onSuccess!(workout)
            }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func EditWorkout(oldWorkout: WorkoutInfo, name: String, descr: String, type: String, isPublic: Bool, onSuccess: ((WorkoutInfo)->Void)?, onFail:((String?)->Void)?) {
        self.p_updatingTime -= 5
        ServerManager.shared.EditWorkout(oldWorkout: oldWorkout,
                                         workoutName: name,
                                         workoutDescription: descr,
                                         workoutType: type,
                                         isPublic: isPublic,
                                         onSuccess: { (workout: WorkoutInfo) in
                                            if (onSuccess != nil) {
                                                onSuccess!(workout)
                                            }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func SetWorkoutLocation(location: String, isGooglePlace:Bool, workout: WorkoutInfo,  onSuccess: ((WorkoutInfo)->Void)?, onFail:((String?)->Void)?) {
        ServerManager.shared.SetWorkoutLocation(workoutID: workout.id, name: location,
                                                address: location,
                                                isGooglePlace: isGooglePlace,
                                                onSuccess: { (WorkoutInfo) in
            if (onSuccess != nil) {
                workout.location_name = location
                onSuccess!(workout)
            }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func GetUserWorkouts(user:UserInfo, onCompleted:(([WorkoutInfo])->Void)?) {
        DispatchQueue.global().async {
            let result = self.workoutsAll.filter({ (info:WorkoutInfo) -> Bool in
                return info.organizer_name == user.username && info.is_active
            })
            onCompleted?(result)
        }
    }
    
    func DeleteWorkout(workout: WorkoutInfo, onSuccess: ((WorkoutInfo)->Void)?, onFail:((String?)->Void)?) {
        ServerManager.shared.WorkoutDelete(workout: workout,
                                                onSuccess: { () in
            DBService.shared.PerformBlockInDBQueue {
                let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                if (saved.count > 0) {
                    for entity in saved {
                        (entity as? WorkoutEntity)?.is_active = false
                    }
                }
            }
            if (onSuccess != nil) {
                workout.is_active = false
                if let index = self.workoutsAll.index(where: { (savedWorkout:WorkoutInfo) -> Bool in
                    return savedWorkout.id == workout.id
                }) {
                    self.workoutsAll.remove(at: index)
                }
                self.filterWorkouts()
                onSuccess!(workout)
                
 /*
                let info = [WorkoutsManager.INFO_UNCHANGED: [],
                            WorkoutsManager.INFO_UPDATED: [workout],
                            WorkoutsManager.INFO_NEW: [],
                            WorkoutsManager.INFO_UNUSED: []]
                NotificationCenter.default.post(name: WorkoutsManager.WORKOUTS_DID_UPDATED, object: nil, userInfo: info)
*/
            }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }


// MARK: Comments
    func PostComment(comment: String,
                     workout: WorkoutInfo,
                     taggedUsers: [String]? = nil,
                     taggedEmails: [String]? = nil,
                     taggedPhones: [String]? = nil,
                     taggedDisplayNames: [String]? = nil,
                     onSuccess: ((CommentInfo)->Void)?,
                     onFail:((String?)->Void)?) {
        ServerManager.shared.PostWorkoutComment(workoutID: workout.id,
                                                text: comment,
                                                users: taggedUsers,
                                                emails: taggedEmails,
                                                phones: taggedPhones,
                                                displayNames: taggedDisplayNames,
                                                onSuccess: { (commentInfo:CommentInfo) in
            DBService.shared.PerformBlockInDBQueue {
                let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                if (saved.count > 0) {
                    let newCommentEntity = DBService.shared.CreateObjectFromCurrentThread(CommentEntity.self) as! CommentEntity
                    commentInfo.toEntity(newCommentEntity)
                    (saved[0] as! WorkoutEntity).addToComments(newCommentEntity)
                }
            }
            workout.comments.append(commentInfo)
            workout.comments = workout.comments.sorted(by: { (comment1:CommentInfo, comment2: CommentInfo) -> Bool in
                return comment1.init_time_original < comment2.init_time_original
            })
            if (onSuccess != nil) {
                onSuccess!(commentInfo)
            }
        }, onFail: { (message: String?) in
            NSLog("Fail: \(message)")
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func EditComment(comment: CommentInfo,
                     workout: WorkoutInfo,
                     text: String,
                     taggedUsers: [String]? = nil,
                     taggedEmails: [String]? = nil,
                     taggedPhones: [String]? = nil,
                     onSuccess: ((CommentInfo)->Void)?,
                     onFail:((String?)->Void)?) {
        ServerManager.shared.EditWorkoutComment(workoutID: workout.id,
                                                commentID: comment.id,
                                                text: text,
                                                users: taggedUsers,
                                                emails: taggedEmails,
                                                phones: taggedPhones,
                                                onSuccess: { (commentInfo:CommentInfo) in
                                                    DBService.shared.PerformBlockInDBQueue {
                                                        let saved = DBService.shared.AllObjectsFromCurrentThread(CommentEntity.self, filter: "id=\(comment.id)")
                                                        if (saved.count > 0) {
                                                            for old in saved {
                                                                if let oldComment = old as? CommentEntity {
                                                                    commentInfo.toEntity(oldComment)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    if (onSuccess != nil) {
                                                        onSuccess!(commentInfo)
                                                    }
        }, onFail: { (message: String?) in
            NSLog("Fail: \(message)")
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func DeleteComment(comment: CommentInfo,
                     workout: WorkoutInfo,
                     onSuccess: ((CommentInfo)->Void)?,
                     onFail:((String?)->Void)?) {
        ServerManager.shared.DeleteWorkoutComment(workoutID: workout.id,
                                                commentID: comment.id,
                                                onSuccess: { (commentInfo:CommentInfo) in
                                                    comment.is_active = false
                                                    DBService.shared.PerformBlockInDBQueue {
                                                        let saved = DBService.shared.AllObjectsFromCurrentThread(CommentEntity.self, filter: "id=\(comment.id)")
                                                        if (saved.count > 0) {
                                                            for old in saved {
                                                                if let oldComment = old as? CommentEntity {
                                                                    oldComment.is_active = false
                                                                    oldComment.is_activeDefTrue = false
                                                                }
                                                            }
                                                            DBService.shared.RefreshObjects(saved)
                                                        }
                                                    }
                                                    if (onSuccess != nil) {
                                                        onSuccess!(comment)
                                                    }
        }, onFail: { (message: String?) in
            NSLog("Fail: \(message)")
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func updateComments(workout: WorkoutInfo,
                        onSuccess: ((_ workout: WorkoutInfo, _ hasUpdates: Bool)->Void)?,
                        onFail:((String?)->Void)?) {
        ServerManager.shared.GetWorkoutComments(workoutID: workout.id,
                                                onSuccess: { (comments:[CommentInfo]) in
            // merge comments
            DBService.shared.PerformBlockInDBQueue {
                var hasUpdates = false
                
                var updated = [CommentInfo]()
                var new = [CommentInfo]()
                var unchanged = [CommentInfo]()
                var unused = [CommentInfo]()
                for newComment in comments {
                    var isFounded = false
                    for oldComment in workout.comments {
                        if (oldComment.id == newComment.id) {
                            isFounded = true
                            if (oldComment.init_time_original == newComment.init_time_original
                                && oldComment.username == newComment.username
                                && oldComment.text == newComment.text) {
                                unchanged.append(oldComment)
                            } else {
                                let saved = DBService.shared.AllObjectsFromCurrentThread(CommentEntity.self, filter: "id=\(oldComment.id)")
                                if (saved.count > 0) {
                                    newComment.toEntity(saved[0] as! CommentEntity)
                                    oldComment.fromEntity(saved[0] as? CommentEntity)
                                    updated.append(oldComment)
                                    hasUpdates = true
                                }
                            }
                        }
                    }
                    if (!isFounded) {
                        let newCommentEntity = DBService.shared.CreateObjectFromCurrentThread(CommentEntity.self) as! CommentEntity
                        newComment.toEntity(newCommentEntity)
                        let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                        if (saved.count > 0) {
                            (saved[0] as! WorkoutEntity).addToComments(newCommentEntity)
                        }
                        workout.comments.append(newComment)
                        workout.comments = workout.comments.sorted(by: { (comment1:CommentInfo, comment2: CommentInfo) -> Bool in
                            return comment1.init_time_original < comment2.init_time_original
                        })
                        new.append(newComment)
                        hasUpdates = true
                    }
                }
                
                if (onSuccess != nil) {
                    onSuccess!(workout, hasUpdates)
                }
                                                        
                if (hasUpdates) {
                    let userInfo = [WorkoutsManager.INFO_UNCHANGED: unchanged,
                                    WorkoutsManager.INFO_UPDATED: updated,
                                    WorkoutsManager.INFO_NEW: new,
                                    WorkoutsManager.INFO_UNUSED: unused]
                    NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_COMMENTS_UPDATED, object: workout, userInfo: userInfo)
                }
            }
        }, onFail: { (message:String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    
// MARK: Likes
    func Like(workout: WorkoutInfo,
              onSuccess: ((WorkoutInfo)->Void)?,
              onFail:((String?)->Void)?) {
        ServerManager.shared.Like(workoutID: workout.id,
                                  onSuccess: { (workoutID: Int64, likes:Int64) in
            workout.likes = UInt(likes)
            if (onSuccess != nil) {
                onSuccess!(workout)
            }
            NotificationCenter.default.post(name: WorkoutsManager.WORKOUT_LIKES_UPDATED, object: workout)
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    func updateLikes(workout: WorkoutInfo,
                     onSuccess: ((_ workout:WorkoutInfo, _ hasUpdates: Bool)->Void)?,
                        onFail:((String?)->Void)?) {
        ServerManager.shared.GetLikes(workoutID: workout.id,
                                      onSuccess: { (workoutID:Int64, likes:Int64) in
            var hasUpdates = false
            if (workout.likes != UInt(likes)) {
                hasUpdates = true
            }
            workout.likes = UInt(likes)
            DBService.shared.PerformBlockInDBQueue {
                let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                if (saved.count > 0) {
                    (saved[0] as! WorkoutEntity).likesCount = likes
                }
            }
            if (onSuccess != nil) {
                onSuccess!(workout, hasUpdates)
            }
            if (hasUpdates) {
                NotificationCenter.default.post(name:WorkoutsManager.WORKOUT_LIKES_UPDATED, object: workout)
            }
        }, onFail: { (message:String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
    
// MARK: - Join
    func Join(workout: WorkoutInfo,
              onSuccess: ((WorkoutInfo)->Void)?,
              onFail:((String?)->Void)?) {
        ServerManager.shared.Join(workoutID: workout.id,
                                  onSuccess: {
            if let user = ServerManager.shared.currentUser {
                if (!workout.attendees_names.contains(user.username)) {
                    workout.attendees_names.append(user.username)
                    DBService.shared.PerformBlockInDBQueue {
                        let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                        if (saved.count > 0) {
                            (saved[0] as! WorkoutEntity).attendees_names = NSSet(array: workout.attendees_names)
                        }
                    }
                    if (onSuccess != nil) {
                        onSuccess!(workout)
                    }
                }
            }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }

    func Leave(workout: WorkoutInfo,
              onSuccess: ((WorkoutInfo)->Void)?,
              onFail:((String?)->Void)?) {
        ServerManager.shared.Leave(workoutID: workout.id,
                                  onSuccess: {
                                    if let user = ServerManager.shared.currentUser {
                                        if (workout.attendees_names.contains(user.username)) {
                                            workout.attendees_names = workout.attendees_names.filter({ (name:String) -> Bool in
                                                return user.username != name
                                            })
                                            DBService.shared.PerformBlockInDBQueue {
                                                let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(workout.id)")
                                                if (saved.count > 0) {
                                                    (saved[0] as! WorkoutEntity).attendees_names = NSSet(array: workout.attendees_names)
                                                }
                                            }
                                            self.filterWorkouts()
                                            if (onSuccess != nil) {
                                                onSuccess!(workout)
                                            }
                                        }
                                    }
        }, onFail: { (message: String?) in
            if (onFail != nil) {
                onFail!(message)
            }
        })
    }
    
//MARK: -
    
    @objc func OnContactsUpdated(notify: Notification) {
        if let newContacts = notify.object as? [CNContact] {
            var phones = [String]()
            var emails = [String]()
            var displayNames = [String]()
            for contact in newContacts {
                for phone in contact.phoneNumbers {
                    if (phone.value.stringValue.isPhoneNumber()) {
                        phones.append(phone.value.stringValue.getPhoneNumber())
                    }
                }
                for email in contact.emailAddresses {
                    if ((email.value as String).isEmail()) {
                        emails.append(email.value as String)
                    }
                }
                if (!contact.givenName.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                    displayNames.append(contact.givenName)
                }
            }
            if (phones.count > 0 || emails.count > 0 || displayNames.count > 0) {
                ServerManager.shared.SendFriendsPhones(phones,
                                                       emails: emails,
                                                       userNames: nil,
                                                       displayNames: displayNames,
                                                       onSuccess: nil, onFail: { (message: String?)->Void in
                    NSLog("Fail to send phone: \(message)")
                })
            }
        }
    }
    
    @objc func OnDBOpened(notify: Notification) {
        self.loadFromCoreData()
    }
}


extension WorkoutsManager {
    
    fileprivate func mergeWorkouts(_ workouts:[WorkoutInfo], completed:((_ unchanged:[WorkoutInfo],
        _ updated:[WorkoutInfo], _ new:[WorkoutInfo], _ unused:[WorkoutInfo])->Void)?) {
        DBService.shared.PerformBlockInDBQueue {
            var unchanged = [WorkoutInfo]()
            var updated = [WorkoutInfo]()
            var new = [WorkoutInfo]()
            var unused = [WorkoutInfo]()
            
            for newWorkout in workouts {
                var isFounded = false
                for oldWorkout in self.workoutsAll {
                    if (oldWorkout.id == newWorkout.id) {
                        isFounded = true
                        if (oldWorkout.init_time_original == newWorkout.init_time_original
                            && oldWorkout.modified_time_original == newWorkout.modified_time_original
                            && oldWorkout.organizer_image == newWorkout.organizer_image
                            && oldWorkout.organizer_name == newWorkout.organizer_name
                            && oldWorkout.is_recurring == newWorkout.is_recurring
                            && oldWorkout.isPublic == newWorkout.isPublic
                            && oldWorkout.link == newWorkout.link
                            && oldWorkout.is_active == newWorkout.is_active
                            && oldWorkout.attendees_names == newWorkout.attendees_names) {
                            
                            unchanged.append(oldWorkout)
                        } else {
                            let saved = DBService.shared.AllObjectsFromCurrentThread(WorkoutEntity.self, filter: "id=\(oldWorkout.id)")
                            if (saved.count > 0) {
                                newWorkout.toEntity(saved[0] as! WorkoutEntity)
                                oldWorkout.fromEntity(saved[0] as? WorkoutEntity)
                                
                                updated.append(oldWorkout)
                            } else {
                                let newWorkoutEntity = DBService.shared.CreateObjectFromCurrentThread(WorkoutEntity.self) as! WorkoutEntity
                                newWorkout.toEntity(newWorkoutEntity)
                                oldWorkout.fromEntity(newWorkoutEntity)
                                updated.append(oldWorkout)
                            }
                        }
                        break
                    }
                }
                if (!isFounded) {
                    let newWorkoutEntity = DBService.shared.CreateObjectFromCurrentThread(WorkoutEntity.self) as! WorkoutEntity
                    newWorkout.toEntity(newWorkoutEntity)
                    new.append(newWorkout)
                }
            }
            /*for oldWorkout in self.workoutsPublic {
                var isFounded = false
                for newWorkout in workouts {
                    if (oldWorkout.id == newWorkout.id) {
                        isFounded = true
                        break
                    }
                }
                if (!isFounded) {
                    unused.append(oldWorkout)
                }
            }*/
            
     //       let dispatchGroup = DispatchGroup()
            for workout in updated {
      //          dispatchGroup.enter()
                workout.updateComments(completed: { (WorkoutInfo) in
                    workout.updateLikes(completed: { (WorkoutInfo) in
    //                    dispatchGroup.leave()
                    }, fail: { (message:String?) in
                        NSLog("Fail Update likes: \(message)")
     //                   dispatchGroup.leave()
                    })
                }, fail: { (mess:String?) in
                    workout.updateLikes(completed: { (WorkoutInfo) in
    //                    dispatchGroup.leave()
                    }, fail: { (message:String?) in
                        NSLog("Fail Update likes: \(message)")
     //                   dispatchGroup.leave()
                    })
                })
            }
      //      dispatchGroup.wait(wallTimeout: DispatchWallTime.now() + 15.0)
            /*for workout in unchanged {
                dispatchGroup.enter()
                workout.updateComments(completed: { (WorkoutInfo, hasUpdates:Bool) in
                    workout.updateLikes(completed: { (WorkoutInfo, hasLikesUpdates:Bool) in
                        if (hasUpdates || hasLikesUpdates) {
                            updated.append(workout)
                            unchanged.remove(at: unchanged.index(where: { (saved:WorkoutInfo) -> Bool in
                                return saved.id == workout.id
                            })!)
                        }
                        dispatchGroup.leave()
                    }, fail: { (message:String?) in
                        if (hasUpdates) {
                            updated.append(workout)
                            unchanged.remove(at: unchanged.index(where: { (saved:WorkoutInfo) -> Bool in
                                return saved.id == workout.id
                            })!)
                        }
                        NSLog("Fail Update likes: \(message)")
                        dispatchGroup.leave()
                    })
                }, fail: { (mess:String?) in
                    workout.updateLikes(completed: { (WorkoutInfo, hasLikesUpdates:Bool) in
                        if (hasLikesUpdates) {
                            updated.append(workout)
                            unchanged.remove(at: unchanged.index(where: { (saved:WorkoutInfo) -> Bool in
                                return saved.id == workout.id
                            })!)
                        }
                        dispatchGroup.leave()
                    }, fail: { (message:String?) in
                        NSLog("Fail Update likes: \(message)")
                        dispatchGroup.leave()
                    })
                })
            }
            dispatchGroup.wait()*/
            
            if (completed != nil) {
                completed!(unchanged, updated, new, unused)
            }
        }
    }
    
    fileprivate func filterWorkouts() {
        var friendsWorkouts = [WorkoutInfo]()
        var personalWorkouts = [WorkoutInfo]()
        
        if let user = ServerManager.shared.currentUser {
            for workout in self.workoutsAll {
                if (workout.is_active) {
                    if (self.isFriendsWorkout(workout) || workout.isUserWorkout(user.username)) {
                        friendsWorkouts.append(workout)
                    }
                    if (workout.isUserWorkout(user.username)) {
                        personalWorkouts.append(workout)
                    }
                }
            }
        }
        self.workoutsFriends = friendsWorkouts
        self.workoutsPersonal = personalWorkouts
    }
    
    func isFriendsWorkout(_ workout:WorkoutInfo) -> Bool {
        //if let user = ServerManager.shared.currentUser {
            for follower in FriendsManager.shared.followers {
                if (workout.isUserWorkout(follower.username))
                {
                    return true
                }
            }
            for follower in FriendsManager.shared.following {
                if (workout.isUserWorkout(follower.username))
                {
                    return true
                }
            }
        //}
        return false
    }
}
