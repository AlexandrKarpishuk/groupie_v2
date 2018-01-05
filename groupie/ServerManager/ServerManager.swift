//
//  ServerManager.swift
//  groupie
//
//  Created by Sania on 7/25/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import Alamofire

class ServerManager {
    
    static let shared = ServerManager()
    
    fileprivate(set) var token:String?
    fileprivate let ACCOUNT = "ACCOUNT"
    fileprivate let AUTH_SERVICE = "AUTHSERVICE"
    fileprivate let PASS_SERVICE = "PASSSERVICE"
    fileprivate let FACE_SERVICE = "FACESERVICE"
    
    public static let LOGGED_IN_NOTIFICATION = Notification.Name("ServerManager_LoggedIn")
    public static let LOGGED_OUT_NOTIFICATION = Notification.Name("ServerManager_LoggedOut")
    public static let ON_INTERNET_LOST = Notification.Name("ServerManager_InternetLost")
    public static let ON_INTERNET_OK = Notification.Name("ServerManager_InternetOK")
    
    var isLoggedIn: Bool { get { return self.token != nil } }
    
    var currentUser: UserInfo?
    
    var reachabilityManager: NetworkReachabilityManager = {
        let manager = NetworkReachabilityManager()
        manager!.listener = { (_) in
            if (manager!.isReachable) {
                NotificationCenter.default.post(name: ServerManager.ON_INTERNET_OK, object: nil)
            } else {
                NotificationCenter.default.post(name: ServerManager.ON_INTERNET_LOST, object: nil)
            }
        }
        return manager!
    }()

    
    func Logout() {
        KeyChain.RemovePassword(self.AUTH_SERVICE, account: self.ACCOUNT)
        KeyChain.RemovePassword(self.PASS_SERVICE, account: self.ACCOUNT)
        KeyChain.RemovePassword(self.FACE_SERVICE, account: self.ACCOUNT)
        self.token = nil
        self.currentUser = nil
        NotificationCenter.default.post(name: ServerManager.LOGGED_OUT_NOTIFICATION, object: nil)
    }
    
    func Autologin(onSuccess:((_ userInfo: UserInfo)->Void)?,
                   onFail:((_ message: String?)->Void)?)
    {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else if (KeyChain.GetPassword(self.AUTH_SERVICE, account: self.ACCOUNT) == nil ||
            KeyChain.GetPassword(self.PASS_SERVICE, account: self.ACCOUNT) == nil) {
            if (KeyChain.GetPassword(self.FACE_SERVICE, account: self.ACCOUNT) == nil) {
                if (onFail != nil) {
                    onFail!("Saved credentions not exists")
                }
            } else {
                self.SignInWithFacebook(access_token: KeyChain.GetPassword(self.FACE_SERVICE, account: self.ACCOUNT)!, onSuccess: { (user:UserInfo) in
                    if (onSuccess != nil) {
                        onSuccess!(user)
                    }
                }, onFail: { (message: String?) in
                    if (onFail != nil) {
                        onFail!(message)
                    }
                })

            }
        } else {
            self.SignIn(username: KeyChain.GetPassword(self.AUTH_SERVICE, account: self.ACCOUNT)!,
                        password: KeyChain.GetPassword(self.PASS_SERVICE, account: self.ACCOUNT)!,
                        onSuccess:
                { (user: UserInfo) in
                    if (onSuccess != nil) {
                        onSuccess!(user)
                    }
            }, onFail: { (message: String?) in
                if (onFail != nil) {
                    onFail!(message)
                }
            })
        }
    }
    
    func SignUp (username: String,
                 firstName: String,
                 lastName: String,
                 password: String,
                 email: String,
                 onSuccess:((_ userInfo: UserInfo)->Void)?,
                 onFail:((_ message: String?)->Void)?)
    {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SignUp(username: username, firstName: firstName, lastName: lastName, password: password, email: email, onSuccess: { (json: [String : Any]?) in
                if let token = json?["token"] as? String { self.token = token }
                KeyChain.SetPassword(self.AUTH_SERVICE, account: self.ACCOUNT, password: username)
                KeyChain.SetPassword(self.PASS_SERVICE, account: self.ACCOUNT, password: password)
                if (onSuccess != nil && json != nil) {
                    if let userInfo = json!["user"] as? [String: Any] {
                        self.currentUser = UserInfo(info: userInfo)
                        DBService.shared.OpenDataBase("user\(self.currentUser!.id)", modelFileName: "groupie")
                        onSuccess!(self.currentUser!)
                    } else {
                        if (onFail != nil) {
                            onFail!("Fail parse response")                        
                        }
                    }
                }
                NotificationCenter.default.post(name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func SignIn (username: String,
                 password: String,
                 onSuccess:((_ userInfo: UserInfo)->Void)?,
                 onFail:((_ message: String?)->Void)?)
    {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SignIn(userName: username,
                       password: password,
                       onSuccess: { (json: [String : Any]?) in
                if let token = json?["token"] as? String { self.token = token }
                KeyChain.SetPassword(self.AUTH_SERVICE, account: self.ACCOUNT, password: username)
                KeyChain.SetPassword(self.PASS_SERVICE, account: self.ACCOUNT, password: password)
                if (onSuccess != nil && json != nil) {
                    if let userInfo = json!["user"] as? [String: Any] {
                        self.currentUser = UserInfo(info: userInfo)
                        DBService.shared.OpenDataBase("user\(self.currentUser!.id)", modelFileName: "groupie")
                        onSuccess!(self.currentUser!)
                    } else {
                        if (onFail != nil) {
                            onFail!("Fail parse response")
                        }
                    }
                }
                NotificationCenter.default.post(name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    
    func SignUpWithFacebook(username: String,
                            firstName: String,
                            lastName: String,
                            access_token: String, email: String,
                                   phone_number: String,
                                   onSuccess:((_ userInfo: UserInfo)->Void)?,
                                   onFail:((_ message: String?)->Void)?)
    {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SignUpWithFacebook(username: username,
                                   firstName: firstName,
                                   lastName: lastName,
                                   access_token: access_token,
                                   email: email,
                                   phone_number: phone_number,
                                   onSuccess: { (json: [String : Any]?) in
                if let token = json?["token"] as? String { self.token = token }
                KeyChain.SetPassword(self.FACE_SERVICE, account: self.ACCOUNT, password: access_token)
                if (onSuccess != nil && json != nil) {
                    if let userInfo = json!["user"] as? [String: Any] {
                        self.currentUser = UserInfo(info: userInfo)
                        DBService.shared.OpenDataBase("user\(self.currentUser!.id)", modelFileName: "groupie")
                        onSuccess!(self.currentUser!)
                    } else {
                        if (onFail != nil) {
                            onFail!("Fail parse response")
                        }
                    }
                }
                NotificationCenter.default.post(name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func SignInWithFacebook(access_token: String,
                            onSuccess:((_ userInfo: UserInfo)->Void)?,
                            onFail:((_ message: String?)->Void)?)
    {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SignInWithFacebook(access_token: access_token,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if let token = json?["token"] as? String { self.token = token }
                    KeyChain.SetPassword(self.FACE_SERVICE, account: self.ACCOUNT, password: access_token)
                    if (onSuccess != nil && json != nil) {
                        if let userInfo = json!["user"] as? [String: Any] {
                            self.currentUser = UserInfo(info: userInfo)
                            DBService.shared.OpenDataBase("user\(self.currentUser!.id)", modelFileName: "groupie")
                            onSuccess!(self.currentUser!)
                        } else {
                            if (onFail != nil) {
                                onFail!("Fail parse response")
                            }
                        }
                    }
                    NotificationCenter.default.post(name:ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetMeInfo(onSuccess:((_ userInfo: UserInfo)->Void)?,
                   onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetMeInfo(authToken: self.token!, onSuccess: { (json: [String : Any]?) in
                if (onSuccess != nil && json != nil) {
                    self.currentUser = UserInfo(info: json)
                    onSuccess!(self.currentUser!)
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func SetMeName(_ name: String, onSuccess:((_ userInfo: UserInfo)->Void)?,
                   onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SetMeName(authToken: self.token!, newName: name, onSuccess: { (json: [String : Any]?) in
                if (onSuccess != nil && json != nil) {
                    self.currentUser = UserInfo(info: json)
                    onSuccess!(self.currentUser!)
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetUserInfo(userNick: String,
                     onSuccess:((_ userInfo: UserInfo)->Void)?,
                     onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            if (self.token != nil) {
                API.GetUserInfo(authToken: self.token!,
                                userNick: userNick,
                                onSuccess: { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(UserInfo(info: json))
                    }
                }, onFail: { (response: DataResponse<Any>) in
                    if (onFail != nil) {
                        onFail!(self.DecodeError(response: response))
                    }
                })
            } else {
                onFail?("Token not valid")
            }
        }
    }
    
    func SetAvatarImage(jpegData: Data,
                     onSuccess:((_ userInfo: UserInfo)->Void)?,
                     onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SetAvatarImageJPEG(authToken: self.token!,
                            imageJPEG: jpegData,
                            onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    self.currentUser = UserInfo(info: json)
                                    onSuccess!(self.currentUser!)
                                }
            }, onFail: { (error: Error?) in
                if (onFail != nil) {
                    onFail!("\(error)")
                }
            })
        }
    }
        
    
// MARK: - Follow
    func Follow(userNick: String,
                onSuccess:((_ success: Bool)->Void)?,
                onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.Follow(authToken: self.token!,
                       userNick: userNick,
                       onSuccess: { (json: [String : Any]?) in
                if (onSuccess != nil && json != nil) {
                    if (json?["status"] != nil) {
                        onSuccess!(self.parseStatus(status: json?["status"]))
                    } else {
                        onFail?("Unknown error")
                    }
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func UnFollow(userNick: String,
                onSuccess:((_ success: Bool)->Void)?,
                onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.UnFollow(authToken: self.token!,
                       userNick: userNick,
                       onSuccess: { (json: [String : Any]?) in
                        if (onSuccess != nil && json != nil) {
                            if (json?["status"] != nil) {
                                onSuccess!(self.parseStatus(status: json?["status"]))
                            } else {
                                onFail?("Unknown error")
                            }
                        }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetFollowers(onSuccess:((_ users: [UserInfo])->Void)?,
                      onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetFollowers(authToken: self.token!,
                             onSuccess: { (json: [[String : Any]]?) in
                if (onSuccess != nil && json != nil) {
                    var result = [UserInfo]()
                    for userJson in json! {
                        result.append(UserInfo(info: userJson))
                    }
                    onSuccess!(result)
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetFollowing(onSuccess:((_ users: [UserInfo])->Void)?,
                      onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetFollowing(authToken: self.token!,
                             onSuccess: { (json: [[String : Any]]?) in
                if (onSuccess != nil && json != nil) {
                    var result = [UserInfo]()
                    for userJson in json! {
                        result.append(UserInfo(info: userJson))
                    }
                    onSuccess!(result)
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
// MARK: - Phones
    func SendFriendsPhones(_ phones: [String]?,
                           emails: [String]?,
                           userNames: [String]?,
                           displayNames: [String]?,
                           onSuccess:(()->Void)?,
                           onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SendFriendsPhones(authToken: self.token!,
                                  phones: phones,
                                  emails: emails,
                                  userNames: userNames,
                                  displayNames: displayNames,
                                  onSuccess: onSuccess) { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            }
        }
    }
    
    func Invite(numbers: [String],
               emails: [String],
               onSuccess:(()->Void)?,
               onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.Invite(authToken: self.token!,
                              numbers: numbers,
                              emails: emails,
                              onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    onSuccess!()
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    
    func SearchUsers(request: String?,
                onSuccess:(([UserInfo])->Void)?,
                onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SearchUsers(authToken: self.token!,
                       request: request,
                       onSuccess: { (json: [[String : Any]]?) in
                        var result = [UserInfo]()
                        if (json != nil) {
                            for jsonInfo in json! {
                                result.append(UserInfo(info: jsonInfo))
                            }
                        }
                        if (onSuccess != nil && json != nil) {
                            onSuccess!(result)
                        }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
// MARK: - Workouts
    func GetWorkoutsPersonal(userNick: String,
                             onSuccess:((_ workouts: [WorkoutInfo])->Void)?,
                             onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetWorkoutsPersonal(authToken: self.token!,
                                    userNick: userNick,
                                    onSuccess: { (json: [[String : Any]]?) in
                    if (onSuccess != nil) {
                        if (json != nil) {
                            var result = [WorkoutInfo]()
                            for jsonInfo in json! {
                                result.append(WorkoutInfo(info: jsonInfo))
                            }
                            onSuccess!(result)
                        } else {
                            if (onFail != nil) {
                                onFail!("Fail while parsing response")
                            }
                        }
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetWorkoutsFriends(onSuccess:((_ workouts: [WorkoutInfo])->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetWorkoutsFriends(authToken: self.token!,
                                   onSuccess: { (json: [[String : Any]]?) in
                if (onSuccess != nil) {
                    if (json != nil) {
                        var result = [WorkoutInfo]()
                        for jsonInfo in json! {
                            result.append(WorkoutInfo(info: jsonInfo))
                        }
                        onSuccess!(result)
                    } else {
                        if (onFail != nil) {
                            onFail!("Fail while parsing response")
                        }
                    }
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetWorkoutsPublic(lastModified: String? = nil,
                           onSuccess:((_ workouts: [WorkoutInfo])->Void)?,
                           onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetWorkoutsPublic(authToken: self.token!,
                                  lastModified: lastModified,
                                  onSuccess: { (json: [[String : Any]]?) in
                if (onSuccess != nil) {
                    if (json != nil) {
                        var result = [WorkoutInfo]()
                        for jsonInfo in json! {
                            result.append(WorkoutInfo(info: jsonInfo))
                        }
                        onSuccess!(result)
                    } else {
                        if (onFail != nil) {
                            onFail!("Fail while parsing response")
                        }
                    }
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func PostWorkout(workoutName: String,
                     workoutDescription: String,
                     workoutType: String,
                     isPublic: Bool,
                     onSuccess:((_ workout: WorkoutInfo)->Void)?,
                     onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.PostWorkout(authToken: self.token!,
                            name: workoutName,
                            desc: workoutDescription,
                            workoutType: workoutType,
                            isPublic: isPublic,
                            onSuccess: { (json: [String : Any]?) in
                if (onSuccess != nil && json != nil) {
                    onSuccess!(WorkoutInfo(info: json))
                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func EditWorkout(oldWorkout: WorkoutInfo,
                     workoutName: String,
                     workoutDescription: String,
                     workoutType: String,
                     isPublic: Bool,
                     onSuccess:((_ workout: WorkoutInfo)->Void)?,
                     onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.EditWorkout(authToken: self.token!,
                            oldWorkout: oldWorkout,
                            name: workoutName,
                            desc: workoutDescription,
                            workoutType: workoutType,
                            isPublic: isPublic,
                            onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    onSuccess!(WorkoutInfo(info: json))
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetWorkout(workoutID: Int64,
                    onSuccess:((_ workout: WorkoutInfo)->Void)?,
                    onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetWorkout(authToken: self.token!,
                           workoutID: workoutID,
                           onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    onSuccess!(WorkoutInfo(info: json))
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func WorkoutInvite(workoutID: Int64,
                       friends: [String],
                       numbers: [String],
                       emails: [String],
                       onSuccess:(()->Void)?,
                       onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.WorkoutInvite(authToken: self.token!,
                              workoutID: workoutID,
                              friends: friends,
                              numbers: numbers,
                              emails: emails,
                              onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    onSuccess!()
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    func WorkoutInviteLeave(workoutID: Int64,
                       friends: [String],
                       onSuccess:(()->Void)?,
                       onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.WorkoutInviteLeave(authToken: self.token!,
                              workoutID: workoutID,
                              userNames: friends,
                              onSuccess: { (json: [String : Any]?) in
                                if (onSuccess != nil && json != nil) {
                                    onSuccess!()
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func WorkoutDelete(workout: WorkoutInfo,
                       onSuccess:(()->Void)?,
                       onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.DeleteWorkout(authToken: self.token!,
                              workoutID: workout.id,
                              onSuccess: { (json: [String : Any]?) in            
                                if (onSuccess != nil /* && json != nil */) {
                                    onSuccess!()
                                }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
// MARK: - Location
    
    func GetWorkoutLocation(workoutID: Int64,
                            onSuccess:((_ workout: WorkoutInfo)->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetWorkoutLocation(authToken: self.token!,
                                   workoutID: workoutID,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(WorkoutInfo(info: json))
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func SetWorkoutLocation(workoutID: Int64,
                             name: String,
                             address: String,
                             isGooglePlace: Bool,
                             onSuccess:((_ workout: WorkoutInfo)->Void)?,
                             onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SetWorkoutLocation(authToken: self.token!,
                                   workoutID: workoutID,
                                   name: name,
                                   location: address,
                                   isGooglePlace: isGooglePlace,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(WorkoutInfo(info: json))
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
// MARK: - Comments
    func GetWorkoutComments(workoutID: Int64,
                            onSuccess:((_ comments: [CommentInfo])->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            if (self.isLoggedIn) {
                API.GetWorkoutComments(authToken: self.token!,
                                       workoutID: workoutID,
                                       onSuccess:
                    { (json: [[String : Any]]?) in
                        if (onSuccess != nil) {
                            if (json == nil) {
                                onSuccess!([CommentInfo]())
                            } else {
                                var result = [CommentInfo]()
                                for jsonInfo in json! {
                                    result.append(CommentInfo(info: jsonInfo))
                                }
                                onSuccess!(result)
                            }
                        }
                }, onFail: { (response: DataResponse<Any>) in
                    if (onFail != nil) {
                        onFail!(self.DecodeError(response: response))
                    }
                })
            } else {
                if (onFail != nil) {
                    onFail!("User is not logged in")
                }
            }
        }
    }
    
    func PostWorkoutComment(workoutID: Int64,
                            text: String,
                            users: [String]? = nil,
                            emails: [String]? = nil,
                            phones: [String]? = nil,
                            displayNames: [String]? = nil,
                            onSuccess:((_ commentInfo: CommentInfo)->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SetWorkoutComments(authToken: self.token!,
                                   workoutID: workoutID,
                                   text: text,
                                   names: users,
                                   emails: emails,
                                   phones: phones,
                                   displayNames: displayNames,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(CommentInfo(info: json))
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func EditWorkoutComment(workoutID: Int64,
                            commentID: Int64,
                            text: String,
                            users: [String]? = nil,
                            emails: [String]? = nil,
                            phones: [String]? = nil,
                            onSuccess:((_ commentInfo: CommentInfo)->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.EditWorkoutComment(authToken: self.token!,
                                   workoutID: workoutID,
                                   commentID: commentID,
                                   text: text,
                                   names: users,
                                   emails: emails,
                                   phones: phones,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(CommentInfo(info: json))
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func DeleteWorkoutComment(workoutID: Int64,
                            commentID: Int64,
                            onSuccess:((_ commentInfo: CommentInfo)->Void)?,
                            onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.DeleteWorkoutComment(authToken: self.token!,
                                   workoutID: workoutID,
                                   commentID: commentID,
                                   onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!(CommentInfo(info: json))
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
// MARK: - Likes
    func GetLikes(workoutID: Int64,
                  onSuccess:((_ workoutID: Int64, _ likesCount:Int64)->Void)?,
                  onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            if (self.isLoggedIn) {
                API.GetWorkoutLikes(authToken: self.token!,
                                    workoutID: workoutID,
                                    onSuccess:
                    { (json: [String : Any]?) in
                        if (onSuccess != nil) {
                            if let likes = json?["count"] as? Int {
                                onSuccess!(workoutID, Int64(likes))
                            } else {
                                if (onFail != nil) {
                                    onFail!("Uknown error")
                                }
                            }
                        }
                }, onFail: { (response: DataResponse<Any>) in
                    if (onFail != nil) {
                        onFail!(self.DecodeError(response: response))
                    }
                })
            } else {
                onFail?("User is not logged in")
            }
        }
    }
    
    func Like(workoutID: Int64,
              onSuccess:((_ workoutID: Int64, _ likesCount:Int64)->Void)?,
              onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.PostWorkoutLike(authToken: self.token!,
                                workoutID: workoutID,
                                onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil) {
                        if let likes = json?["count"] as? Int {
                            onSuccess!(workoutID, Int64(likes))
                        } else {
                            if (onFail != nil) {
                                onFail!("Uknown error")
                            }
                        }
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func GetMyLikes(onSuccess:((_ workoutIDs: Set<Int64>)->Void)?,
                    onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.GetMyLikes(authToken: self.token!,
                                onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil) {
                        if let likes = json?["feeds"] as? [Int64] {
                            onSuccess!(Set(likes))
                        } else {
                            if (onFail != nil) {
                                onFail!("Uknown error")
                            }
                        }
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func Dislike(workoutID: Int64,
              onSuccess:((_ workoutID: Int64, _ likesCount:Int64)->Void)?,
              onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.DeleteLike(authToken: self.token!,
                                workoutID: workoutID,
                                onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil) {
                        if let likes = json?["count"] as? Int {
                            onSuccess!(workoutID, Int64(likes))
                        }
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
// MARK: - Join
    func Join(workoutID: Int64,
              onSuccess:(()->Void)?,
              onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.Join(authToken: self.token!,
                    workoutID: workoutID,
                    onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!()
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    func Leave(workoutID: Int64,
              onSuccess:(()->Void)?,
              onFail:((_ message: String?)->Void)? ) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.Leave(authToken: self.token!,
                     workoutID: workoutID,
                     onSuccess:
                { (json: [String : Any]?) in
                    if (onSuccess != nil && json != nil) {
                        onSuccess!()
                    }
            }, onFail: { (response: DataResponse<Any>) in
                if (onFail != nil) {
                    onFail!(self.DecodeError(response: response))
                }
            })
        }
    }
    
    
    // MARK: - Notifications
    func RegisterForNotifications(apnsToken: String) {
        if (self.reachabilityManager.isReachable && self.isLoggedIn) {
            API.RegisterForNotifications(authToken: self.token!,
                                         apnsToken: apnsToken,
                                         onSuccess: { (_: [String : Any]?) in
                                            
            }, onFail: { (response:DataResponse<Any>) in
                NSLog("\(String(describing: self.DecodeError(response: response)))")
            })
        }
    }
    
    func UnRegisterForNotifications(apnsToken: String, completed: (()->Void)?) {
        if (self.reachabilityManager.isReachable && self.isLoggedIn) {
            API.UnRegisterForNotifications(authToken: self.token!,
                                         apnsToken: apnsToken,
                                         onSuccess: { (_: [String : Any]?) in
                                            completed?()
            }, onFail: { (response:DataResponse<Any>) in
                NSLog("\(String(describing: self.DecodeError(response: response)))")
                completed?()
            })
        }
    }
    
    func OnNotifications(onSuccess:((_ userInfo: UserInfo)->Void)?,
                         onFail:((_ message: String?)->Void)?) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.OnNotifications(authToken: self.token!,
                                         onSuccess: { (userInfo: [String : Any]?) in
                onSuccess?(UserInfo(info: userInfo))
            }, onFail: { (response:DataResponse<Any>) in
                NSLog("\(String(describing: self.DecodeError(response: response)))")
                onFail?(self.DecodeError(response: response))
            })
        }
    }
    
    func OffNotifications(onSuccess:((_ userInfo: UserInfo)->Void)?,
                         onFail:((_ message: String?)->Void)?) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.OffNotifications(authToken: self.token!,
                                onSuccess: { (userInfo: [String : Any]?) in
                                    onSuccess?(UserInfo(info: userInfo))
            }, onFail: { (response:DataResponse<Any>) in
                NSLog("\(String(describing: self.DecodeError(response: response)))")
                onFail?(self.DecodeError(response: response))
            })
        }
    }
    
    func SendTestNotification(onSuccess:(()->Void)?,
                          onFail:((_ message: String?)->Void)?) {
        if (!self.reachabilityManager.isReachable) {
            onFail?("No internet connection!")
        } else {
            API.SendTestNotification(authToken: self.token!,
                                 onSuccess: { (userInfo: [String : Any]?) in
                                    onSuccess?()
            }, onFail: { (response:DataResponse<Any>) in
                NSLog("\(String(describing: self.DecodeError(response: response)))")
                onFail?(self.DecodeError(response: response))
            })
        }
    }
    
// MARK: - Decode server errors
    func DecodeError(response: DataResponse<Any>) -> String? {
        guard (response.data != nil) else {
            return nil
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
            if let message = json["message"] as? String {
                return message
            }
            if let detail = json["detail"] as? String {
                return detail
            }
            var resultString: String = ""
            for key in json.keys {
                if (resultString.isEmpty) {
                    resultString = "\(key): \(String(describing: json[key]!))"
                } else {
                    resultString = "\(resultString)\n \(key): \(String(describing: json[key]!))"
                }
            }
            if (resultString.isEmpty == false) {
                NSLog("Decode error: \(resultString)")
                return resultString
            }
        } catch (_) {
            let str = String(data: response.data!, encoding: .utf8)
            if (str != nil && !str!.isEmpty) {
                NSLog("Decode error: \(str!)")
                return str
            }
        }
        return nil
    }


    fileprivate func parseStatus(status: Any?) -> Bool {
        
        if (status != nil) {
            switch (status!) {
            case let res as Bool:
                return res

            case let res as String:
                switch (res) {
                case "ok":
                    return true

                case "OK":
                    return true

                case "Ok":
                    return true

                case "success":
                    return true

                case "Success":
                    return true

                case "true":
                    return true

                case "True":
                    return true

                    
                default:
                    break
                }
                break
                
            case let res as Int:
                return (res != 0)

            case let res as NSNumber:
                return res.boolValue

            default:
                break
            }

        }
        return false
    }
}
