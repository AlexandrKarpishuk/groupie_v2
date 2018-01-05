//
//  ContactsManager.swift
//  groupie
//
//  Created by Sania on 6/21/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import Contacts

class ContactsManager {
    static let shared = ContactsManager()
    
    fileprivate var p_contactsStore = CNContactStore()
    fileprivate var p_contacts = [CNContact]()
    fileprivate var p_newContacts = [CNContact]()
    fileprivate var p_contactsDict = [String: [CNContact]]()
    fileprivate var p_isAccess: Bool = false
    fileprivate var p_updateTimer: Timer? = nil
    fileprivate var p_needSendNotification: Bool = false
    fileprivate var p_emptyUpdateCounter: Int = 0
    fileprivate var p_lock = NSRecursiveLock()
    
    static fileprivate let p_emptyUpdateMAXCount: Int = 180 // 1 minute
    
    public static let CONTACTS_LOADED_NOTIFICATION = Notification.Name("ContactsManager_ContacsLoaded") // max 3 notification is second (object: 'new contacts', please use 'contacts')
    
    public var contacts: [CNContact] {
        get { return self.p_contacts }
    }
    public var isAccess: Bool {
        get { return self.p_isAccess }
    }
    public var contactsDictionary: [String: [CNContact]] {
        get { return self.p_contactsDict }
    }
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(LoadContactsAsync), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    fileprivate func StartUpdateTimer() {
        DispatchQueue.main.async {  // main queue has RunLoop
            if (self.p_updateTimer == nil) {
                self.p_updateTimer = Timer.scheduledTimer(timeInterval: 0.33,
                                                          target: self,
                                                          selector: #selector(self.onUpdateTimer),
                                                          userInfo: nil,
                                                          repeats: true)
            }
        }
    }
    fileprivate func StopUpdateTimer() {
        DispatchQueue.main.async {
            if (self.p_updateTimer != nil) {
                self.p_updateTimer!.invalidate()
                self.p_updateTimer = nil
            }
        }
    }
    
    @objc public func onUpdateTimer() {
        // Main thread
        if (self.p_needSendNotification) {
            self.p_needSendNotification = false
            
            self.p_emptyUpdateCounter = 0
            
            NotificationCenter.default.post(name: ContactsManager.CONTACTS_LOADED_NOTIFICATION, object: self.p_newContacts)
            self.p_newContacts = [CNContact]()
        } else {
            self.p_emptyUpdateCounter += 1
            if (self.p_emptyUpdateCounter >= ContactsManager.p_emptyUpdateMAXCount) {
                self.StopUpdateTimer()
            }
        }
    }
    
    public func RequestRights() {
        DispatchQueue.global().async {
            self.p_contactsStore.requestAccess(for: .contacts) { (granted:Bool, error:Error?) in
                self.p_isAccess = granted
                
                if (self.isAccess) {
                    self.LoadContactsAsync()
                }
            }
        }
    }
    
    @objc public func LoadContactsAsync() {
        self.StartUpdateTimer()
        DispatchQueue.global().async {
            do {
                let request = CNContactFetchRequest(keysToFetch:
                    [CNContactGivenNameKey as CNKeyDescriptor,
                     CNContactPhoneNumbersKey as CNKeyDescriptor,
                     CNContactEmailAddressesKey as CNKeyDescriptor,
                     CNContactThumbnailImageDataKey as CNKeyDescriptor,
                     CNContactMiddleNameKey as CNKeyDescriptor,
                     CNContactFamilyNameKey as CNKeyDescriptor])
                try self.p_contactsStore.enumerateContacts(with: request) { (contact:CNContact, res:UnsafeMutablePointer<ObjCBool>) in
                    
                    self.AddContact(contact)
                }
            } catch (_) {
                
            }
        }
    }
    
    fileprivate func AddContact(_ contact: CNContact) {
        
        self.p_lock.lock()
        
        if (!self.p_contacts.contains(contact)) {
            self.p_contacts.append(contact)
            self.p_newContacts.append(contact)
            
            if (contact.givenName.count > 0) {
                let firstLetter = contact.givenName.substring(to: contact.givenName.index(after: contact.givenName.startIndex)).uppercased()

                if (self.p_contactsDict[firstLetter] == nil) {
                    self.p_contactsDict[firstLetter] = [contact]
                } else {
                    if var oldContacts = self.p_contactsDict[firstLetter] {
                        oldContacts.append(contact)
                        self.p_contactsDict[firstLetter] = oldContacts.sorted(by: { (contact1: CNContact, contact2: CNContact) -> Bool in
                            return contact1.givenName < contact2.givenName
                        })
                    }
                }
                
      //          NSLog("Contacts: \(self.p_contactsDict)")
            }
     
            self.p_needSendNotification = true
        }
        
        self.p_lock.unlock()
    }
}
