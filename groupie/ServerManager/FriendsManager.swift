//
//  FriendsManager.swift
//  groupie
//
//  Created by Sania on 8/16/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class FriendsManager {
    
    static var shared = FriendsManager()
    
    static let NOTIFICATION_FOLLOWERS = Notification.Name("Followers")
    static let NOTIFICATION_FOLLOWING = Notification.Name("Following")
    
    fileprivate(set) var followers = [UserInfo]()
    fileprivate(set) var following = [UserInfo]()
    
    init() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onLoggedIN),
                                               name: ServerManager.LOGGED_IN_NOTIFICATION,
                                               object: nil)
    }
    
    
    @objc func onLoggedIN(_ notify: Notification) {
        self.UpdateFollow()
        self.UpdateFollowing()
    }
    
    func UpdateFollow() {
        ServerManager.shared.GetFollowers(onSuccess: { (users:[UserInfo]) in
            NSLog("Followers")
            self.followers = users
            var message = "Count: \(users.count) "
            for user in users {
                message += "'\(user.username)' "
            }
       //     NotificationCenter.default.post(name: FriendsManager.NOTIFICATION_FOLLOWERS, object: message)
        }, onFail: { (message:String?) in
            NSLog("\(message)")
       //     NotificationCenter.default.post(name: FriendsManager.NOTIFICATION_FOLLOWERS, object: "Fail when updating followers")
        })
    }
    func UpdateFollowing() {
        ServerManager.shared.GetFollowing(onSuccess: { (users:[UserInfo]) in
            self.following = users
            NSLog("Following")
            var message = "Count: \(users.count) "
            for user in users {
                message += "'\(user.username)' "
            }
        //    NotificationCenter.default.post(name: FriendsManager.NOTIFICATION_FOLLOWING, object: message)
        }, onFail: { (message:String?) in
            NSLog("\(message)")
        //    NotificationCenter.default.post(name: FriendsManager.NOTIFICATION_FOLLOWING, object: "Fail when updating following")
        })
    }
    
    func Follow(user: UserInfo,
                onSuccess:((_ success: Bool)->Void)?,
                onFail:((_ message: String?)->Void)? ) {
        ServerManager.shared.Follow(userNick: user.username, onSuccess: { (success:Bool) in
            if (success) {
                var userIsAvailable = false
           /*     for follower in self.followers {
                    if (follower.id == user.id) {
                        userIsAvailable = true
                        break
                    }
                }*/
                if (!userIsAvailable) {
                    for follower in self.following {
                        if (follower.id == user.id) {
                            userIsAvailable = true
                            break
                        }
                    }
                }
                if (!userIsAvailable) {
                    self.following.append(user)
                }
            }
            onSuccess?(success)
        }, onFail:  { (message:String?) in
            NSLog("\(message)")
        })
    }
    
    func UnFollow(user: UserInfo,
                onSuccess:((_ success: Bool)->Void)?,
                onFail:((_ message: String?)->Void)? ) {
        ServerManager.shared.UnFollow(userNick: user.username, onSuccess: { (success:Bool) in
            if (success) {
                self.following = self.following.filter({ (savedUser:UserInfo) -> Bool in
                    return savedUser.id != user.id
                })
             /*   self.followers = self.followers.filter({ (savedUser:UserInfo) -> Bool in
                    return savedUser.id != user.id
                })*/

            }
            onSuccess?(success)
        }, onFail:  { (message:String?) in
            NSLog("\(message)")
        })
    }
    
    func InviteFriendsToWorkout(workout: WorkoutInfo,
                                friends:[String],
                                onSuccess:((_ success: Bool)->Void)?,
                                onFail:((_ message: String?)->Void)? ) {
        
        var userNames = [String]()
        var numbers = [String]()
        var emails = [String]()
        
        for item in friends {
            if (item.isEmail()) {
                emails.append(item)
            } else if (item.isPhoneNumber()) {
                numbers.append(item.getPhoneNumber())
            } else {
                if (self.FriendWith(nick: item) != nil) {
                    userNames.append(item)
                } else {
                    var isContact = false
                    for contact in ContactsManager.shared.contacts {
                        if (contact.givenName == item) {
                            if (!contact.phoneNumbers.isEmpty) {
                                for phone in contact.phoneNumbers {
                                    if (phone.value.stringValue.isPhoneNumber()) {
                                        numbers.append(phone.value.stringValue.getPhoneNumber())
                                        isContact = true
                                        break
                                    }
                                }
                            }
                            if (!isContact && !contact.emailAddresses.isEmpty) {
                                for email in contact.emailAddresses {
                                    if ((email.value as String).isEmail()) {
                                        emails.append(email.value as String)
                                        isContact = true
                                        break
                                    }
                                }
                            }
                            if (!isContact) {
                                userNames.append(item)
                            }
                            break
                        }
                    }
                    if (!isContact) {
                        userNames.append(item)
                    }
                }
            }
        }
        
        ServerManager.shared.WorkoutInvite(workoutID: workout.id,
                                           friends: userNames,
                                           numbers: numbers,
                                           emails: emails,
                                           onSuccess: {
                                            workout.attendees_names.append(contentsOf: friends)
                                            onSuccess?(true)
        }, onFail: { (message:String?) in
            NSLog("\(message)")
        })
    }
    
    func LeaveFriendsFromWorkout(workout: WorkoutInfo,
                                friends:[String],
                                onSuccess:((_ success: Bool)->Void)?,
                                onFail:((_ message: String?)->Void)? ) {
        ServerManager.shared.WorkoutInviteLeave(workoutID: workout.id, friends: friends, onSuccess: {
            workout.attendees_names = workout.attendees_names.filter({ (item:String) -> Bool in
                return !friends.contains(item)
            })
            onSuccess?(true)
        }, onFail: { (message:String?) in
            NSLog("\(message)")
            onFail?(message)
        })
  /*      var userNames = [String]()
        var numbers = [String]()
        var emails = [String]()
        
        for item in friends {
            if (item.isEmail()) {
                emails.append(item)
            } else if (item.isPhoneNumber()) {
                numbers.append(item.getPhoneNumber())
            } else {
                if (self.FriendWith(nick: item) != nil) {
                    userNames.append(item)
                } else {
                    var isContact = false
                    for contact in ContactsManager.shared.contacts {
                        if (contact.givenName == item) {
                            if (!contact.phoneNumbers.isEmpty) {
                                for phone in contact.phoneNumbers {
                                    if (phone.value.stringValue.isPhoneNumber()) {
                                        numbers.append(phone.value.stringValue.getPhoneNumber())
                                        isContact = true
                                        break
                                    }
                                }
                            }
                            if (!isContact && !contact.emailAddresses.isEmpty) {
                                for email in contact.emailAddresses {
                                    if ((email.value as String).isEmail()) {
                                        emails.append(email.value as String)
                                        isContact = true
                                        break
                                    }
                                }
                            }
                            if (!isContact) {
                                userNames.append(item)
                            }
                            break
                        }
                    }
                }
            }
        }
        
        ServerManager.shared.WorkoutInvite(workoutID: workout.id,
                                           friends: userNames,
                                           numbers: numbers,
                                           emails: emails,
                                           onSuccess: {
                                            workout.attendees_names.append(contentsOf: friends)
                                            onSuccess?(true)
        }, onFail: { (message:String?) in
            NSLog("\(message)")
        })*/
        
    }
    
    func FriendWith(nick: String?) -> UserInfo? {
        if (nick != nil) {
            for follower in self.followers {
                if (follower.username.range(of: nick!, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil) {
                    return follower
                }
                if (nick!.range(of: follower.username, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil) {
                    return follower
                }
            }

            for follower in self.following {
                if (follower.username.range(of: nick!, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil) {
                    return follower
                }
                if (nick!.range(of: follower.username, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil) {
                    return follower
                }
            }

        }
        return nil
    }
}
