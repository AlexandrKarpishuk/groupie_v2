//
//  CommentsInfo.swift
//  groupie
//
//  Created by Sania on 7/29/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class CommentInfo {
    
    var id: Int64 = 0
    var username = ""
    var init_time: Date?
    var init_time_original = ""
    var text = ""
    var avatarURL: String = ""
    var mentioned_names = [String]()
    var mentioned_emails = [String]()
    var mentioned_phones = [String]()
    var invites_phones = [String]()
    var invites_emails = [String]()
    var invites_names = [String]()
    var is_active: Bool = true
    var modified_time: Date?
    var modified_time_original = ""
    var feed_id: Int64 = 0
    
    
    init(info: [String: Any]?) {
        if let id = info?["id"] as? Int64                           { self.id = id }
        if let feed_id = info?["feed_id"] as? Int64                 { self.feed_id = feed_id }
        if let is_active = info?["is_active"] as? Bool              { self.is_active = is_active }
        if let username = info?["username"] as? String              { self.username = username }
        if let init_time = info?["init_time"] as? String  {
            self.init_time_original = init_time
            self.init_time = Date(dateString: init_time)
        }
        if let text = info?["text"] as? String                      { self.text = text }
        
        if let modified_time = info?["modified_time"] as? String  {
            self.modified_time_original = modified_time
            self.modified_time = Date(dateString: modified_time)
        }
        
        if let names = info?["mentioned_names"] as? [String] {
            self.mentioned_names = names
        }
        if let emails = info?["mentioned_emails"] as? [String] {
            self.mentioned_emails = emails
        }
        if let phones = info?["mentioned_phones"] as? [String] {
            self.mentioned_phones = phones
        }
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
    
    func fromEntity(_ entity: CommentEntity?) {
        if (entity != nil) {
            self.id = entity!.id
            if (entity!.username != nil)            {self.username = entity!.username!}
            if (entity!.text != nil)                {self.text = entity!.text!}
            if (entity!.init_time != nil) {
                self.init_time_original = entity!.init_time!
                self.init_time = Date(dateString: self.init_time_original)
            }
            if (entity!.modified_time != nil) {
                self.modified_time_original = entity!.modified_time!
                self.modified_time = Date(dateString: self.modified_time_original)
            }
            self.is_active = entity!.is_activeDefTrue
            self.feed_id = entity!.feed_id
            if (entity!.mentioned_names != nil) {
                self.mentioned_names = [String]()
                for name in entity!.mentioned_names! {
                    self.mentioned_names.append(name)
                }
            }
            if (entity!.mentioned_emails != nil) {
                self.mentioned_emails = [String]()
                for name in entity!.mentioned_emails! {
                    self.mentioned_emails.append(name)
                }
            }
            if (entity!.mentioned_phones != nil) {
                self.mentioned_phones = [String]()
                for name in entity!.mentioned_phones! {
                    self.mentioned_phones.append(name)
                }
            }
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
            self.avatarURL = entity!.avatarURL ?? ""
        }
    }
    
    func toEntity(_ entity:CommentEntity) {
        entity.id = self.id
        entity.username = self.username
        entity.text = self.text
        entity.init_time = self.init_time_original
        entity.is_activeDefTrue = self.is_active
        entity.feed_id = self.feed_id
        entity.modified_time = self.modified_time_original
        entity.mentioned_emails = self.mentioned_emails
        entity.mentioned_names = self.mentioned_names
        entity.mentioned_phones = self.mentioned_phones
        entity.invites_names = self.invites_names
        entity.invites_phones = self.invites_phones
        entity.invites_emails = self.invites_emails
        entity.avatarURL = self.avatarURL
    }
    
    func save() {
        
    }
}
