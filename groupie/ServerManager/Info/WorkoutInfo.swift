//
//  WorkoutInfo.swift
//  groupie
//
//  Created by Sania on 7/29/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class WorkoutInfo {
    
    var id: Int64 = 0
    var link = ""
    var init_time: Date?
    var init_time_original = ""
    var modified_time: Date?
    var modified_time_original = ""
    var location_name = ""
    var workout_type = ""
    var is_recurring = false
    var is_active = false
    var descr = ""
    var organizer_name = ""
    var isPublic = false
    var attendees_names = [String]()
    var invites_phones = [String]()
    var invites_emails = [String]()
    var invites_names = [String]()
    var comments = [CommentInfo]()
    var likes: UInt = 0
    var organizer_image: String = ""
    var is_google_place: Bool = true
    
    init(info: [String: Any]?) {
        if let id = info?["id"] as? Int64                           { self.id = id }
        if let link = info?["link"] as? String                      { self.link = link }
        if let init_time = info?["init_time"] as? String  {
            self.init_time_original = init_time
            self.init_time = Date(dateString: init_time)
        }
        if let modified_time = info?["modified_time"] as? String  {
            self.modified_time_original = modified_time
            self.modified_time = Date(dateString: modified_time)
        }
        if let location_name = info?["location_name"] as? String    { self.location_name = location_name }
        if let workout_type = info?["workout_type"] as? String      { self.workout_type = workout_type }
        if let is_recurring = info?["is_recurring"] as? Bool        { self.is_recurring = is_recurring }
        if let descr = info?["description"] as? String              { self.descr = descr }
        if let organizer_name = info?["organizer_name"] as? String  { self.organizer_name = organizer_name }
        if let organizer_image = info?["organizer_image"] as? String  { self.organizer_image = organizer_image }
        if let isPublic = info?["public"] as? Bool                  { self.isPublic = isPublic }
        if let names = info?["attendees_names"] as? [String]        { self.attendees_names = names}
        if let likesCount = info?["likesCount"] as? Int             {
            self.likes = UInt(likesCount)
        }
        if let active = info?["is_active"] as? Bool                  { self.is_active = active}
        if let is_google_place = info?["is_google_place"] as? Bool  { self.is_google_place = is_google_place}
        if let invitations = info?["invites"] as? [String: Any] {
            if let invPhones = invitations["phone_numbers"] as? [String] {
                self.invites_phones = invPhones
            }
            if let invEmails = invitations["emails"] as? [String] {
                self.invites_emails = invEmails
            }
            if let invDisplayNames = invitations["names"] as? [String] {
                self.invites_names = invDisplayNames
            }
        }
    }
    
    func fromEntity(_ entity: WorkoutEntity?) {
        if (entity != nil) {
            self.id = entity!.id
            if (entity!.link != nil)            {self.link = entity!.link!}
            if (entity!.location_name != nil)   {self.location_name = entity!.location_name!}
            if (entity!.workout_type != nil)    {self.workout_type = entity!.workout_type!}
            self.is_recurring = entity!.is_recurring
            if (entity!.desc != nil)            {self.descr = entity!.desc!}
            if (entity!.organizer_name != nil)  {self.organizer_name = entity!.organizer_name!}
            if (entity!.organizer_image != nil) {self.organizer_image = entity!.organizer_image!}
            self.isPublic = entity!.isPublic
            self.is_active = entity!.is_active
            self.is_google_place = entity!.is_google_place
            self.likes = UInt(entity!.likesCount)
            if (entity!.init_time != nil) {
                self.init_time_original = entity!.init_time!
                self.init_time = Date(dateString: self.init_time_original)
            }
            if (entity!.modified_time != nil) {
                self.modified_time_original = entity!.modified_time!
                self.modified_time = Date(dateString: self.modified_time_original)
            }
            
            self.attendees_names = [String]()
            if (entity!.attendees_names != nil) {
                
                for name in entity!.attendees_names! {
                    self.attendees_names.append(name as! String)
                }
            }
            self.comments = [CommentInfo]()
            if (entity!.comments != nil) {
                for commentEntity in entity!.comments! {
                    let commentInfo = CommentInfo(info:[:])
                    commentInfo.fromEntity(commentEntity as? CommentEntity)
                    if (commentInfo.init_time != nil) {
                        self.comments.append(commentInfo)
                    }
                }
            }
            self.comments = self.comments.sorted(by: { (comment1:CommentInfo, comment2:CommentInfo) -> Bool in
                return comment1.init_time_original < comment2.init_time_original
            })
            if (entity!.invites_phones != nil) {
                self.invites_phones = [String]()
                for name in entity!.invites_phones! {
                    self.invites_phones.append(name)
                }
            }
            if (entity!.invites_emails != nil) {
                self.invites_emails = [String]()
                for name in entity!.invites_emails! {
                    self.invites_emails.append(name)
                }
            }
            if (entity!.invites_names != nil) {
                self.invites_names = [String]()
                for name in entity!.invites_names! {
                    self.invites_names.append(name)
                }
            }
        }
    }
    
    func toEntity(_ entity:WorkoutEntity) {
        entity.id = self.id
        entity.link = self.link
        entity.init_time = self.init_time_original
        entity.modified_time = self.modified_time_original
        entity.location_name = self.location_name
        entity.workout_type = self.workout_type
        entity.is_recurring = self.is_recurring
        entity.is_active = self.is_active
        entity.is_google_place = self.is_google_place
        entity.desc = self.descr
        entity.organizer_name = self.organizer_name
        entity.organizer_image = self.organizer_image
        entity.isPublic = self.isPublic
        entity.likesCount = Int64(self.likes)
        entity.attendees_names = NSSet(array: self.attendees_names)
        if (entity.comments != nil) {
            entity.removeFromComments(entity.comments!)
            for comment in self.comments {
                let saved = DBService.shared.AllObjectsFromCurrentThread(CommentEntity.self, filter: "id=\(comment.id)")
                entity.addToComments(NSSet(array: saved as! [Any]))
            }
        }
        entity.invites_names = self.invites_names
        entity.invites_phones = self.invites_phones
        entity.invites_emails = self.invites_emails
    }
    
    func updateComments(completed:((_ workout:WorkoutInfo, _ hasUpdates:Bool)->Void)?, fail:((String?)->Void)?) {
        WorkoutsManager.shared.updateComments(workout: self, onSuccess: { (WorkoutInfo, hasUpdates:Bool) in
            completed?(self, hasUpdates)
        }) { (message:String?) in
            fail?(message)
        }
    }
    
    func updateLikes(completed:((_ workout:WorkoutInfo, _ hasUpdates:Bool)->Void)?, fail:((String?)->Void)?) {
        WorkoutsManager.shared.updateLikes(workout: self, onSuccess: { (WorkoutInfo, hasUpdates:Bool) in
            completed?(self, hasUpdates)
        }, onFail:  { (message:String?) in
            fail?(message)
        })
    }

    func isUserWorkout(_ user:String) -> Bool {
        return self.organizer_name == user || self.attendees_names.contains(user)
    }
}
