//
//  UserInfo.swift
//  groupie
//
//  Created by Sania on 7/26/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class UserInfo {
    
    var id: Int64 = 0
    var fb_id = ""
    var username = ""
    var first_name = ""
    var last_name = ""
    var display_name = ""
    var phone_number = ""
    var email = ""
    var profile_picture_url = ""
    var allow_notifications: Bool = true

    var lastUpdate: Date?
    
    init(info: [String: Any]?) {
        if let id = info?["id"] as? Int64                           { self.id = id }
        if let fb_id = info?["fb_id"] as? String                    { self.fb_id = fb_id }
        if let username = info?["username"] as? String              { self.username = username }
        if let first_name = info?["first_name"] as? String          { self.first_name = first_name }
        if let last_name = info?["last_name"] as? String            { self.last_name = last_name }
        if let display_name = info?["display_name"] as? String      { self.display_name = display_name }
        if let phone_number = info?["phone_number"] as? String      { self.phone_number = phone_number }
        if let email = info?["email"] as? String                    { self.email = email }
        if let profile_picture_url = info?["profile_picture_url"] as? String { self.profile_picture_url = profile_picture_url }
        
        if let allow_Notifications = info?["allow_notifications"] as? Bool {
            self.allow_notifications = allow_Notifications
        }
    }
    
    
    func fromEntity(_ entity: UserEntity?) {
        if (entity != nil) {
            self.id = entity!.id
            if (entity!.fb_id != nil)      {self.fb_id = entity!.fb_id!}
            if (entity!.username != nil)   {self.username = entity!.username!}
            if (entity!.first_name != nil) {self.first_name = entity!.first_name!}
            self.allow_notifications = entity!.allow_notifications
            if (entity!.last_name != nil)  {self.last_name = entity!.last_name!}
            if (entity!.display_name != nil){self.display_name = entity!.display_name!}
            if (entity!.phone_number != nil){self.phone_number = entity!.phone_number!}
            if (entity!.email != nil)       {self.email = entity!.email!}
            if (entity!.profile_picture_url != nil){self.profile_picture_url = entity!.profile_picture_url!}
        }
    }
    
    func toEntity(_ entity:UserEntity) {
        entity.id = self.id
        entity.fb_id = self.fb_id
        entity.username = self.username
        entity.first_name = self.first_name
        entity.last_name = self.last_name
        entity.display_name = self.display_name
        entity.phone_number = self.phone_number
        entity.email = self.email
        entity.profile_picture_url = self.profile_picture_url
        entity.allow_notifications = self.allow_notifications
    }
}
