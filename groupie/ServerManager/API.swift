//
//  API.swift
//  groupie
//
//  Created by Sania on 7/25/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class API : NSObject {
#if DEBUG
    static fileprivate let DEBUG_STATISTIC = true
#else
    static fileprivate let DEBUG_STATISTIC = false
#endif
    static var baseURL:URL = URL(string: "https://groupieapidev.herokuapp.com/api/")!
    static var baseHeaders = ["Content-Type": "application/json",
                              "Host": "groupieapidev.herokuapp.com",
                              "Upgrade": "HTTP/1.1",
                //              "Allow": "OPTIONS, POST",
                              "Vary": "Accept"]

    static func SignUp(username: String,
                       firstName: String,
                       lastName: String,
                       password: String,
                       email: String,
                       onSuccess: ((_ data:[String:Any]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)?)
    {
        let path = "profile/sign_up/"

        let parameters = ["username": username,
                          "first_name": firstName,
                          "last_name": lastName,
                          "password": password,
                          "email": email]
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: baseHeaders)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }

    static func SignIn(userName: String,
                       password: String,
                       onSuccess: ((_ data:[String:Any]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)?)
    {
        let path = "profile/sign_in/"
        
        let parameters = ["username": userName,
                          "password": password]
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: baseHeaders)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func SignUpWithFacebook(username: String,
                                   firstName: String,
                                   lastName: String,
                                   access_token: String,
                                   email: String,
                                   phone_number: String,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)?)
    {
        let path = "profile/sign_up_with_facebook/"

        let parameters = ["username": username,
                          "first_name": firstName,
                          "last_name": lastName,
                          "access_token": access_token,
                          "email": email,
                          "phone_number": phone_number]
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: baseHeaders)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }

    static func SignInWithFacebook(access_token: String,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)?)
    {
        let path = "profile/sign_in_with_facebook/"
        
        let parameters = ["access_token": access_token]
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: baseHeaders)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func GetMeInfo(authToken: String,
                          onSuccess: ((_ data:[String:Any]?)->Void)?,
                          onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/me/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func SetMeName(authToken: String,
                          newName: String,
                          onSuccess: ((_ data:[String:Any]?)->Void)?,
                          onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/me/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let parameters = ["username": newName]
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func GetUserInfo(authToken: String,
                            userNick: String,
                            onSuccess: ((_ data:[String:Any]?)->Void)?,
                            onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/user/\(userNick)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    
    static func SetAvatarImageJPEG(authToken: String,
                            imageJPEG: Data,
                            onSuccess: ((_ data:[String:Any]?)->Void)?,
                            onFail: ((_ error: Error?)->Void)?) {
        let path = "profile/me/image/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        headers["Content-Disposition"] = "form-data; name=\"file\"; filename=\"123.jpg\""
        headers["Content-Type"] = "image/jpg"

        
        Alamofire.upload(multipartFormData: { (multipart:MultipartFormData) in
            multipart.append(imageJPEG, withName: "file", fileName: "123.jpg", mimeType: "image/jpg")
        }, usingThreshold: 0,
           to: baseURL.appendingPathComponent(path),
           method: HTTPMethod.post,
           headers: headers) { (result:SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON{
                    response in
                    if let data = response.result.value as? [String:Any]{
                        DispatchQueue.main.async {
                            onSuccess?(data)
                        }
                    } else {
                        DispatchQueue.main.async {
                            onFail?(response.error)
                        }
                    }
                    
                }
                break
            case .failure(let encodingError):
                NSLog("\(encodingError)")
                DispatchQueue.main.async {
                    onFail?(encodingError)
                }
                break
                
            }
        }
    }
    
// MARK: - Friends
    static func SendFriendsPhones(authToken: String,
                                  phones: [String]?,
                                  emails: [String]?,
                                  userNames: [String]?,
                                  displayNames: [String]?,
                                  onSuccess: (()->Void)?,
                                  onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/import/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: [String]]()
        if (phones != nil) {
            parameters["phone_numbers"] = phones!
        }
        if (emails != nil) {
            parameters["emails"] = emails!
        }
        if (userNames != nil) {
            parameters["user_names"] = userNames!
        }
        if (displayNames != nil) {
            parameters["display_names"] = displayNames!
        }
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!()
                }
        }
    }
    
    static func Invite(authToken: String,
                       numbers: [String],
                       emails: [String],
                       onSuccess: ((_ data:[String:Any]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/invite/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: [String]]()
        if (!numbers.isEmpty) {
            parameters["phone_numbers"] = numbers
        }
        if (!emails.isEmpty) {
            parameters["emails"] = emails
        }
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    

    static func SearchUsers(authToken: String,
                       request: String?,
                       onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        if (request != nil && !request!.isEmpty) {
            let path = "profile/users/"
            
            var headers = baseHeaders
            headers["Authorization"] = "Token \(authToken)"

            var parameters = [String: String]()
            parameters["q"] = request!
            let startDate = Date()
            let requestAF = Alamofire.request(baseURL.appendingPathComponent(path),
                              method: HTTPMethod.get,
                              parameters: parameters,
                              encoding: URLEncoding.default,
                              headers: headers)
            requestAF.validate()
            if (API.DEBUG_STATISTIC) {
                API.printRequest(requestAF, startDate: startDate)
            }
            requestAF.responseJSON { (response) in
                    guard response.result.isSuccess else {
                        if (onFail != nil) {
                            onFail!(response)
                        }
                        return
                    }
                    if (onSuccess != nil) {
                        onSuccess!(response.result.value as? [[String:Any]])
                    }
            }
        } else {
            onSuccess?([])
        }
    }
    
    
    
// MARK: - Follow
    static func Follow(authToken: String,
                       userNick: String,
                       onSuccess: ((_ data:[String:Any]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/follow/"
        
        let parameters = ["username": userNick]
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func UnFollow(authToken: String,
                       userNick: String,
                       onSuccess: ((_ data:[String:Any]?)->Void)?,
                       onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/follow/"
        
        let parameters = ["username": userNick]
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    
    
    static func GetFollowers(authToken: String,
                             onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                             onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/followers/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    static func GetFollowing(authToken: String,
                             onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                             onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "profile/following/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    
// MARK: - Workouts
    static func GetWorkoutsPersonal(authToken: String,
                                    userNick: String,
                                    onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                                    onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "workout/feeds/"
        
        let parameters = ["mode": "personal", "username": userNick]
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    static func GetWorkoutsFriends(authToken: String,
                                    onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                                    onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "workout/feeds/"
        
        let parameters = ["mode": "friends"]
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    static func GetWorkoutsPublic(authToken: String,
                                  lastModified: String? = nil,
                                  onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                                  onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "workout/feeds/"
        
        var parameters: [String: Any]? = nil
        
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        if (lastModified != nil) {
            parameters = ["last_modified": lastModified!]
        }
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: parameters,
                          encoding: URLEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    
    static func PostWorkout(authToken: String,
                            name: String,
                            desc: String,
                            workoutType: String,
                            isPublic: Bool,
                            onSuccess: ((_ data:[String:Any]?)->Void)?,
                            onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "workout/feeds/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: Any]()
        parameters["name"] = name
        parameters["description"] = desc
        parameters["workout_type"] = workoutType
        parameters["public"] = isPublic
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func EditWorkout(authToken: String,
                            oldWorkout: WorkoutInfo,
                            name: String,
                            desc: String,
                            workoutType: String,
                            isPublic: Bool,
                            onSuccess: ((_ data:[String:Any]?)->Void)?,
                            onFail: ((_ response: DataResponse<Any>)->Void)?) {
        let path = "workout/feeds/\(oldWorkout.id)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: Any]()
        parameters["name"] = name
        parameters["description"] = desc
        parameters["workout_type"] = workoutType
        parameters["public"] = isPublic
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.put,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func GetWorkout(authToken: String,
                           workoutID: Int64,
                           onSuccess: ((_ data:[String:Any]?)->Void)?,
                           onFail: ((_ response: DataResponse<Any>)->Void)? ) {
    
        let path = "workout/feeds/\(workoutID)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func DeleteWorkout(authToken: String,
                           workoutID: Int64,
                           onSuccess: ((_ data:[String:Any]?)->Void)?,
                           onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
// MARK: Location
    static func GetWorkoutLocation(authToken: String,
                           workoutID: Int64,
                           onSuccess: ((_ data:[String:Any]?)->Void)?,
                           onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/location/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func SetWorkoutLocation(authToken: String,
                                   workoutID: Int64,
                                   name: String,
                                   location: String,
                                   isGooglePlace: Bool,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/location/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let parameters: [String : Any] = ["name": name, "address": location, "is_google_place": isGooglePlace]
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func WorkoutInvite(authToken: String,
                              workoutID: Int64,
                              friends: [String],
                              numbers: [String],
                              emails: [String],
                              onSuccess: ((_ data:[String:Any]?)->Void)?,
                              onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "workout/feeds/\(workoutID)/invite/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: [String]]()
        if (!friends.isEmpty) {
            parameters["user_names"] = friends
        }
        if (!numbers.isEmpty) {
            parameters["phone_numbers"] = numbers
        }
        if (!emails.isEmpty) {
            parameters["emails"] = emails
        }
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func WorkoutInviteLeave(authToken: String,
                              workoutID: Int64,
                              userNames: [String],
                              onSuccess: ((_ data:[String:Any]?)->Void)?,
                              onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "workout/feeds/\(workoutID)/leave/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters = [String: [String]]()
        if (!userNames.isEmpty) {
            parameters["user_names"] = userNames
        }
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    
// MARK: - Likes
    static func GetWorkoutLikes(authToken: String,
                                workoutID: Int64,
                                onSuccess: ((_ data:[String:Any]?)->Void)?,
                                onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/likes/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func PostWorkoutLike(authToken: String,
                                workoutID: Int64,
                                onSuccess: ((_ data:[String:Any]?)->Void)?,
                                onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/likes/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"

        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func GetMyLikes(authToken: String,
                           onSuccess: ((_ data:[String:Any]?)->Void)?,
                           onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/likes/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func DeleteLike(authToken: String,
                           workoutID: Int64,
                           onSuccess: ((_ data:[String:Any]?)->Void)?,
                           onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "workout/feeds/\(workoutID)/likes/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        NSLog("Get Likes Start: \(workoutID)")
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                NSLog("Get Likes Completed: \(workoutID)")

                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
// MARK: Comments
    static func GetWorkoutComments(authToken: String,
                                   workoutID: Int64,
                                   onSuccess: ((_ data:[[String:Any]]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/comments/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
     //   NSLog("Get Comments Start: \(workoutID)")
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.get,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
      //          NSLog("Get Comments Completed: \(workoutID)")
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [[String:Any]])
                }
        }
    }
    
    static func SetWorkoutComments(authToken: String,
                                   workoutID: Int64,
                                   text: String,
                                   names: [String]? = nil,
                                   emails: [String]? = nil,
                                   phones: [String]? = nil,
                                   displayNames: [String]? = nil,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/comments/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters: [String: Any] = ["text": text]
        if (names != nil) {
            parameters["user_names"] = names!
        }
        if (emails != nil) {
            parameters["emails"] = emails!
        }
        if (phones != nil) {
            parameters["phone_numbers"] = phones!
        }
        if (displayNames != nil) {
            parameters["display_names"] = displayNames!
        }
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func EditWorkoutComment(authToken: String,
                                   workoutID: Int64,
                                   commentID: Int64,
                                   text: String,
                                   names: [String]? = nil,
                                   emails: [String]? = nil,
                                   phones: [String]? = nil,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/comments/\(commentID)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        var parameters: [String: Any] = ["text": text]
        if (names != nil) {
            parameters["user_names"] = names!
        }
        if (emails != nil) {
            parameters["emails"] = emails!
        }
        if (phones != nil) {
            parameters["phone_numbers"] = phones!
        }
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.put,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func DeleteWorkoutComment(authToken: String,
                                   workoutID: Int64,
                                   commentID: Int64,
                                   onSuccess: ((_ data:[String:Any]?)->Void)?,
                                   onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        
        let path = "workout/feeds/\(workoutID)/comments/\(commentID)/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
// MAKR: Join
    static func Join(authToken: String,
                     workoutID: Int64,
                     onSuccess: ((_ data:[String:Any]?)->Void)?,
                     onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "workout/feeds/\(workoutID)/join/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func Leave(authToken: String,
                     workoutID: Int64,
                     onSuccess: ((_ data:[String:Any]?)->Void)?,
                     onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "workout/feeds/\(workoutID)/join/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }

    
//MARK: - Notifications
    static func RegisterForNotifications(authToken: String,
                     apnsToken: String,
                     onSuccess: ((_ data:[String:Any]?)->Void)?,
                     onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "device/apns/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let parameters = ["registration_id": apnsToken]
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    static func UnRegisterForNotifications(authToken: String,
                                         apnsToken: String,
                                         onSuccess: ((_ data:[String:Any]?)->Void)?,
                                         onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/check_device/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let parameters = ["registration_id": apnsToken]
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                                        method: HTTPMethod.post,
                                        parameters: parameters,
                                        encoding: JSONEncoding.default,
                                        headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
            guard response.result.isSuccess else {
                if (onFail != nil) {
                    onFail!(response)
                }
                return
            }
            if (onSuccess != nil) {
                onSuccess!(response.result.value as? [String:Any])
            }
        }
    }
    
    static func OnNotifications(authToken: String,
                             onSuccess: ((_ data:[String:Any]?)->Void)?,
                             onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/allow_notifications/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    
    static func OffNotifications(authToken: String,
                                onSuccess: ((_ data:[String:Any]?)->Void)?,
                                onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/allow_notifications/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.delete,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    static func SendTestNotification(authToken: String,
                                 onSuccess: ((_ data:[String:Any]?)->Void)?,
                                 onFail: ((_ response: DataResponse<Any>)->Void)? ) {
        let path = "profile/test_notification/"
        
        var headers = baseHeaders
        headers["Authorization"] = "Token \(authToken)"
        let startDate = Date()
        let request = Alamofire.request(baseURL.appendingPathComponent(path),
                          method: HTTPMethod.post,
                          parameters: nil,
                          encoding: JSONEncoding.default,
                          headers: headers)
        request.validate()
        if (API.DEBUG_STATISTIC) {
            API.printRequest(request, startDate: startDate)
        }
        request.responseJSON { (response) in
                guard response.result.isSuccess else {
                    if (onFail != nil) {
                        onFail!(response)
                    }
                    return
                }
                if (onSuccess != nil) {
                    onSuccess!(response.result.value as? [String:Any])
                }
        }
    }
    
    
    static func printRequest(_ request: DataRequest, startDate: Date) {
        request.responseString { (responseStr) in
            var body = ""
            var url = ""
            var reqType = ""
            var reqBody = ""
            let reqTime = String(format: "%.6f", Date().timeIntervalSince(startDate))
            if (request.request != nil) {
                if (request.request!.url != nil) {
                    url = request.request!.url!.absoluteString
                }
                if (request.request!.httpMethod != nil) {
                    reqType = request.request!.httpMethod!
                }
                if (request.request!.httpBody != nil) {
                    reqBody = String(data:request.request!.httpBody!, encoding:.utf8) ?? ""
                }
            }
            if (responseStr.value != nil) {
                body = responseStr.value!
            }
         /*   for (key, header) in request.request!.allHTTPHeaderFields! {
                NSLog("\(key): \(header)")
            }*/
            print("\nRequest URL: \(url)\n\(reqType) \(reqTime) sec\nRequest Body: \(reqBody)  \nResponse: \(body)\n")
            NSLog("Request Completed")
        }
    }
}
