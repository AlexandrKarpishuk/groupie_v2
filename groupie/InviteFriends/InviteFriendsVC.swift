//
//  InviteFriendsVC.swift
//  groupie
//
//  Created by Sania on 8/18/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

import Contacts
import FontAwesome_swift

class InviteFriendsVC: GroupieViewController
{
    
    @IBOutlet weak var usersTable: CommentsTable!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var newUserView: UIView!
    @IBOutlet weak var newUserField: UITextField!
    @IBOutlet weak var newUserConstraint: NSLayoutConstraint!
    @IBOutlet weak var vInvite: UIView!
    @IBOutlet weak var vSelect: UIView!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var lSelect: UILabel!
    @IBOutlet weak var cInviteBottom: NSLayoutConstraint!
    @IBOutlet weak var cTitleBottom: NSLayoutConstraint!
    
    
    fileprivate var p_contacts: [CNContact]?
    fileprivate var p_filteredContactsDict: [String: [CNContact]]?
    fileprivate var p_filteredContactsHeaders: [String]?

    var selectedUsers = [Any]()
    var newContacts = [String]()
    
    fileprivate var p_filteredNewContacts = [String]()
    
    fileprivate var p_friends = [UserInfo]()
    fileprivate var p_filteredFriends = [UserInfo]()
    
    fileprivate var plusButton: UIBarButtonItem?
    fileprivate var minusButton: UIBarButtonItem?
    fileprivate var inviteButton: UIBarButtonItem?
    
    var onInviteHandler: ((_ users:[UserInfo])->Void)?
    var onBackHandler: (()->Void)?
    var canShowFriends: Bool = false
    var canShowContacts: Bool = true
    var canUseSearchFriends: Bool = true
    
    override var inputAccessoryView: UIView? { get {
            return self.p_bottomBar
        }
    }
    override var canBecomeFirstResponder: Bool { get {
            return true
        }
    }
    
    fileprivate lazy var p_bottomBar: InviteFriendsBottomBar = {
        let bottomBar = InviteFriendsBottomBar(frame: CGRect(x:0, y:UIScreen.main.bounds.height, width:UIScreen.main.bounds.width, height: 0))
        bottomBar.inviteHandler = {
            self.onInvitePressed()
        }
        return bottomBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //      self.title = "Search Friends"
        //      self.usersTable.delegate = self
        self.usersTable.didLayout = {
            var height = UIScreen.main.bounds.height - self.p_bottomBar.convert(self.p_bottomBar.bounds, to: nil).maxY
            if (height < 0) {
                height = 0
            }
            if (height.isInfinite) {
                height = 0
            }
            self.cTitleBottom.constant = height
            self.cInviteBottom.constant = height
            UIView.animate(withDuration: 0, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        if let placeholder = self.newUserField.placeholder {
            self.newUserField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)])
        }
    }
    
    override func menuWillShow() {
        self.view.endEditing(true)
        self.searchBar.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.onBackHandler == nil) {
            super.viewWillAppear(animated)
            self.navigationItem.title = "Invite New Users"
        } else {
            self.navigationItem.title = "Tag or Invite Users"
            self.navigationController?.navigationBar.tintColor = .white
       //     self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        }
        
        /*    self.navigationController?.navigationBar.topItem?.title = "Search Friends"
         self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]*/
        self.loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onContactsUpdated), name: ContactsManager.CONTACTS_LOADED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(menuWillShow), name: CustomSlideMenuController.NOTIFICATION_MENU_WILL_OPEN, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

        let plusIcon = UIImage(named: "PlusButton")!
        self.plusButton = UIBarButtonItem(image: plusIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.showNew))
        self.plusButton!.tintColor = .white
        
        let minusIcon = UIImage(named: "CloseButton")!
        self.minusButton = UIBarButtonItem(image: minusIcon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.hideNew))
        self.minusButton!.tintColor = .white
        
        self.inviteButton = UIBarButtonItem(title: "Invite", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onInvitePressed))
        self.inviteButton!.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)], for: .normal)

        if (self.navigationItem.rightBarButtonItem == nil) {
            self.navigationItem.setRightBarButtonItems([self.plusButton!/*, self.inviteButton!*/], animated: false)
        }
        
      /*  if (self.onBackHandler != nil) {
            let leftMenuButton = self.navigationItem.leftBarButtonItem
            let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(onBackPressed))
            backButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)], for: .normal)
            self.navigationItem.setLeftBarButtonItems([leftMenuButton!, backButton], animated: true)
        }*/
        
     /*   let backButton = UIBarButtonItem(image: UIImage.fontAwesomeIcon(name: FontAwesome.chevronLeft, textColor: .white, size: CGSize(width:30, height:30)), style: UIBarButtonItemStyle.plain, target: self, action: #selector(onBackPressed))
        self.navigationItem.setLeftBarButton(backButton, animated: true)*/
        
   //     self.reloadInputViews()
        
        if (self.selectedUsers.count > 0) {
            self.showInviteView(animated: false)
        } else {
            self.hideInviteView(animated: false)
        }
    }
    
    @objc @IBAction func onBackPressed() {
        if (self.onBackHandler != nil) {
            self.onBackHandler?()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (self.onBackHandler == nil) {
            super.viewWillAppear(animated)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationItem.setRightBarButtonItems(nil, animated: false)
        self.minusButton = nil
        self.plusButton = nil
        self.inviteButton = nil
    }

    @objc @IBAction func onInvitePressed() {
        if (self.onInviteHandler != nil) {
            var users = [UserInfo]()
            for user in self.selectedUsers {
                switch (user) {
                case is UserInfo:
                    users.append(user as! UserInfo)
                    break
                case is String:
                    let newUser = UserInfo(info: ["username": user as! String])
                    users.append(newUser)
                    break
                case is CNContact:
                    let newUser = UserInfo(info: ["username": (user as! CNContact).givenName])
                    users.append(newUser)
                    break
                default:
                    break
                }
            }
            self.onInviteHandler?(users)
        } else {
            var numbers = [String]()
            var emails = [String]()
            for item in self.selectedUsers {
                if (item is String) {
                    if ((item as! String).isEmail()) {
                        emails.append((item as! String))
                    } else if ((item as! String).isPhoneNumber()) {
                        numbers.append((item as! String).getPhoneNumber())
                    } else {
                        let filtered = self.p_contacts?.filter({ (contact:CNContact) -> Bool in
                            return contact.givenName == (item as! String)
                        })
                        if (filtered != nil && filtered!.count > 0) {
                            let contact = filtered![0]
                            var isEmailFounded = false
                            if (contact.emailAddresses.count > 0) {
                                for email in contact.emailAddresses {
                                    if (email.value as String).isEmail() {
                                        emails.append(email.value as String)
                                        isEmailFounded = true
                                        break
                                    }
                                }
                            }
                            if (!isEmailFounded) {
                                if (contact.phoneNumbers.count > 0) {
                                    for number in contact.phoneNumbers {
                                        if number.value.stringValue.isPhoneNumber() {
                                            numbers.append(number.value.stringValue.getPhoneNumber())
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.view.showActivity()
            ServerManager.shared.Invite(numbers: numbers, emails: emails, onSuccess: { [weak self] in
                DispatchQueue.main.async {
                    self?.view.hideActivity()
                    self?.selectedUsers = [String]()
                    self?.usersTable.reloadData()
                    let alert = UIAlertController(title: "Success",
                                                  message: "Invitation sent",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: { (action: UIAlertAction) in
                                                    
                        NotificationCenter.default.post(name: SidebarViewController.NOTIFICATION_NEED_SHOW_WORKOUTS, object: nil)
                    }))
                    self?.present(alert, animated: true, completion: {

                    })
                }
            }, onFail: { [weak self] (message:String?) in
                DispatchQueue.main.async {
                    self?.view.hideActivity()
                    NSLog("\(String(describing: message))")
                    let alert = UIAlertController(title: "Attention",
                                                  message: "Error occurred when inviting friends",
                                                  preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK",
                                                  style: UIAlertActionStyle.cancel,
                                                  handler: { (action: UIAlertAction) in
                    }))
                    self?.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @objc fileprivate func showNew() {
        self.navigationItem.setRightBarButtonItems([self.minusButton!/*, self.inviteButton!*/], animated: true)
        
        if (self.canShowFriends) {
            self.newUserField.placeholder = "Enter name, phone or email"
        } else {
            self.newUserField.placeholder = "Enter phone or email"
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.newUserConstraint.constant = -self.newUserView.bounds.height
            self.view.layoutSubviews()
        }) { (Bool) in
            self.newUserConstraint.constant = -self.newUserView.bounds.height
            self.view.layoutSubviews()
            
            self.newUserField.becomeFirstResponder()
        }
    }
    
    @objc fileprivate func hideNew() {
        self.navigationItem.setRightBarButtonItems([self.plusButton!/*, self.inviteButton!*/], animated: true)

        self.newUserField.resignFirstResponder()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.newUserConstraint.constant = 0
            self.view.layoutSubviews()
        }) { (Bool) in
            self.newUserConstraint.constant = 0
            self.view.layoutSubviews()
        }
    }
    
    fileprivate func showInviteView(animated: Bool) {
        self.vInvite.isHidden = false
        if (animated) {
            UIView.animate(withDuration: 0.2, animations: {
                self.vInvite.alpha = 1
            }, completion: { (Bool) in
                self.vInvite.alpha = 1
            })
        } else {
            self.vInvite.alpha = 1
        }
      //  self.p_bottomBar.setState(.invite, animated: animated)
    }
    
    fileprivate func hideInviteView(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.2, animations: {
                self.vInvite.alpha = 0
            }, completion: { (Bool) in
                self.vInvite.alpha = 0
                self.vInvite.isHidden = true
            })
        } else {
            self.vInvite.alpha = 0
            self.vInvite.isHidden = true
        }
     //   self.p_bottomBar.setState(.title, animated: animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    public func onContactsUpdated() {
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    public func loadData() {
        let newContacts = ContactsManager.shared.contacts
        //        let oldContacts = self.p_contacts
        // parse new contacts
        
        if (self.canShowContacts) {
            self.p_contacts = newContacts
        } else {
            self.p_contacts = [CNContact]()
        }
        
        if (self.canShowFriends) {
            var friends = FriendsManager.shared.followers
            friends.append(contentsOf: FriendsManager.shared.following)
            friends = friends.sorted(by: { (user1: UserInfo, user2: UserInfo) -> Bool in
                return user1.username < user2.username
            })
            var newFriends = [UserInfo]()
            for friend in friends {
                var isFriendAvailable = false
                for savedFriend in newFriends {
                    if (savedFriend.id == friend.id) {
                        isFriendAvailable = true
                        break
                    }
                }
                if (!isFriendAvailable) {
                    newFriends.append(friend)
                }
            }
            self.p_friends = newFriends
        }
        self.filterContacts(text: self.searchBar.text)
    }
    
    fileprivate func select(user: Any) {
        switch user {
        case is String:
            if (!self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == user as! String)
            })) {
                self.selectedUsers.append(user as! String)
            }
            break
            
        case is UserInfo:
            if (!self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is UserInfo && (item as! UserInfo).username == (user as! UserInfo).username)
            })) {
                self.selectedUsers.append((user as! UserInfo))
            }
            break
            
        case is CNContact:
            if (!self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == (user as! CNContact).givenName)
            })) {
                self.selectedUsers.append((user as! CNContact).givenName)
            }
            break
        
        default:
            break
        }
        if (self.selectedUsers.count > 0) {
            self.showInviteView(animated: true)
        } else {
            self.hideInviteView(animated: true)
        }
    }
    
    fileprivate func deselect(user: Any) {
        switch user {
        case is String:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == user as! String)
            })) {
                let index = self.selectedUsers.index(where: { (item) -> Bool in
                    return (item is String && item as! String == user as! String)
                })
                self.selectedUsers.remove(at: index!)
            }
            break
            
        case is UserInfo:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is UserInfo && (item as! UserInfo).username == (user as! UserInfo).username)
            })) {
                let index = self.selectedUsers.index(where: { (item) -> Bool in
                    return (item is UserInfo && (item as! UserInfo).username == (user as! UserInfo).username)
                })
                self.selectedUsers.remove(at: index!)
            }
            break
            
        case is CNContact:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == (user as! CNContact).givenName)
            })) {
                let index = self.selectedUsers.index(where: { (item) -> Bool in
                    return (item is String && item as! String == (user as! CNContact).givenName)
                })
                self.selectedUsers.remove(at: index!)
            }
            break
            
        default:
            break
        }
        if (self.selectedUsers.count > 0) {
            self.showInviteView(animated: true)
        } else {
            self.hideInviteView(animated: true)
        }
    }
    
    fileprivate func isSelected(user: Any) -> Bool {
        switch user {
        case is String:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == user as! String)
            })) {
                return true
            }
            break
            
        case is UserInfo:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is UserInfo && (item as! UserInfo).username == (user as! UserInfo).username)
            })) {
                return true
            }
            break
            
        case is CNContact:
            if (self.selectedUsers.contains(where: { (item) -> Bool in
                return (item is String && item as! String == (user as! CNContact).givenName)
            })) {
                return true
            }
            break
            
        default:
            break
        }
        
        return false
    }
    
    fileprivate func filterContacts(text: String?) {
        var contacts = self.p_contacts
        var friends = self.p_friends
        var newUsers = self.newContacts
        
        if (text != nil) {
            let trimmedText = text!.trimmingCharacters(in: CharacterSet.whitespaces)
            if (!trimmedText.isEmpty) {
                contacts = contacts?.filter({ (contact: CNContact) -> Bool in
                    var name = contact.givenName
                    if (contact.middleName.isEmpty == false) {
                        if (name.isEmpty == false) {
                            name = name + " "
                        }
                        name = name + contact.middleName
                    }
                    if (contact.familyName.isEmpty == false) {
                        if (name.isEmpty == false) {
                            name = name + " "
                        }
                        name = name + contact.familyName
                    }
                    return (name.range(of: trimmedText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil)
                })
                
                friends = friends.filter({ (user: UserInfo) -> Bool in
                    return (user.username.range(of: trimmedText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil)
                })
                
                newUsers = newUsers.filter({ (name: String) -> Bool in
                    return (name.range(of: trimmedText, options: String.CompareOptions.caseInsensitive, range: nil, locale: nil) != nil)
                })
            }
            if (self.canUseSearchFriends) {
                ServerManager.shared.SearchUsers(request: text!, onSuccess: { [weak self] (users:[UserInfo]) in
                        if let strongSelf = self {
                            if (users.count > 0) {
                                friends.append(contentsOf: users)
                            }
                            strongSelf.p_filteredContactsDict = [String: [CNContact]]()
                            for contact in contacts! {
                                if (contact.givenName.count > 0) {
                                    let firstLetter = contact.givenName.substring(to: contact.givenName.index(after: contact.givenName.startIndex)).uppercased()
                                    
                                    if (strongSelf.p_filteredContactsDict![firstLetter] == nil) {
                                        strongSelf.p_filteredContactsDict![firstLetter] = [contact]
                                    } else {
                                        strongSelf.p_filteredContactsDict![firstLetter]?.append(contact)
                                        strongSelf.p_filteredContactsDict![firstLetter] = strongSelf.p_filteredContactsDict![firstLetter]?.sorted(by: { (contact1: CNContact, contact2: CNContact) -> Bool in
                                            return contact1.givenName < contact2.givenName
                                        })
                                    }
                                }
                            }
                            
                            strongSelf.p_filteredContactsHeaders = Array(strongSelf.p_filteredContactsDict!.keys).sorted(by: { (str1: String, str2: String) -> Bool in
                                return str1 < str2
                            })
                            
                            strongSelf.p_filteredFriends = friends
                            strongSelf.p_filteredNewContacts = newUsers
                            
                            strongSelf.usersTable.reloadData()
                        }
                    }, onFail: { [weak self] (message:String?) in
                        if let strongSelf = self {
                            strongSelf.p_filteredContactsDict = [String: [CNContact]]()
                            for contact in contacts! {
                                if (contact.givenName.count > 0) {
                                    let firstLetter = contact.givenName.substring(to: contact.givenName.index(after: contact.givenName.startIndex)).uppercased()
                                    
                                    if (strongSelf.p_filteredContactsDict![firstLetter] == nil) {
                                        strongSelf.p_filteredContactsDict![firstLetter] = [contact]
                                    } else {
                                        strongSelf.p_filteredContactsDict![firstLetter]?.append(contact)
                                        strongSelf.p_filteredContactsDict![firstLetter] = strongSelf.p_filteredContactsDict![firstLetter]?.sorted(by: { (contact1: CNContact, contact2: CNContact) -> Bool in
                                            return contact1.givenName < contact2.givenName
                                        })
                                    }
                                }
                            }
                            
                            strongSelf.p_filteredContactsHeaders = Array(strongSelf.p_filteredContactsDict!.keys).sorted(by: { (str1: String, str2: String) -> Bool in
                                return str1 < str2
                            })
                            
                            strongSelf.p_filteredFriends = friends
                            strongSelf.p_filteredNewContacts = newUsers
                            
                            strongSelf.usersTable.reloadData()
                        }
                })
            } else {
                self.p_filteredContactsDict = [String: [CNContact]]()
                for contact in contacts! {
                    if (contact.givenName.count > 0) {
                        let firstLetter = contact.givenName.substring(to: contact.givenName.index(after: contact.givenName.startIndex)).uppercased()
                        
                        if (self.p_filteredContactsDict![firstLetter] == nil) {
                            self.p_filteredContactsDict![firstLetter] = [contact]
                        } else {
                            self.p_filteredContactsDict![firstLetter]?.append(contact)
                            self.p_filteredContactsDict![firstLetter] = self.p_filteredContactsDict![firstLetter]?.sorted(by: { (contact1: CNContact, contact2: CNContact) -> Bool in
                                return contact1.givenName < contact2.givenName
                            })
                        }
                    }
                }
                
                self.p_filteredContactsHeaders = Array(self.p_filteredContactsDict!.keys).sorted(by: { (str1: String, str2: String) -> Bool in
                    return str1 < str2
                })
                
                self.p_filteredFriends = friends
                self.p_filteredNewContacts = newUsers
                
                self.usersTable.reloadData()
            }
        } else {
            self.p_filteredContactsDict = [String: [CNContact]]()
            for contact in contacts! {
                if (contact.givenName.count > 0) {
                    let firstLetter = contact.givenName.substring(to: contact.givenName.index(after: contact.givenName.startIndex)).uppercased()
                    
                    if (self.p_filteredContactsDict![firstLetter] == nil) {
                        self.p_filteredContactsDict![firstLetter] = [contact]
                    } else {
                        self.p_filteredContactsDict![firstLetter]?.append(contact)
                        self.p_filteredContactsDict![firstLetter] = self.p_filteredContactsDict![firstLetter]?.sorted(by: { (contact1: CNContact, contact2: CNContact) -> Bool in
                            return contact1.givenName < contact2.givenName
                        })
                    }
                }
            }
            
            self.p_filteredContactsHeaders = Array(self.p_filteredContactsDict!.keys).sorted(by: { (str1: String, str2: String) -> Bool in
                return str1 < str2
            })
            
            self.p_filteredFriends = friends
            self.p_filteredNewContacts = newUsers
            
            self.usersTable.reloadData()
        }
    }
}

extension InviteFriendsVC /* Keyboard */ {
    
    func onKeyboardWillShow(_ notify: Notification?) {
        if (notify?.userInfo != nil) {
            let duration = notify!.userInfo![UIKeyboardAnimationDurationUserInfoKey]  as! TimeInterval
            let endFrame = self.view.convert(notify!.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect, from: nil)
            let options = UIViewAnimationOptions(rawValue:
                (notify!.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                            let deltaY: CGFloat = 0//self.btnInvite.bounds.height //(UIApplication.shared.delegate as! AppDelegate).window!.bounds.height - self.usersTable.convert(self.usersTable.bounds, to: nil).maxY
                            
                            self.usersTable.contentInset.bottom = endFrame.height + deltaY
                            self.usersTable.scrollIndicatorInsets.bottom = endFrame.height + deltaY
                            self.cInviteBottom.constant = endFrame.height
                            self.cTitleBottom.constant = endFrame.height
                            
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    func onKeyboardWillHide(_ notify: Notification?) {
        if (notify?.userInfo != nil) {
            let duration = notify!.userInfo![UIKeyboardAnimationDurationUserInfoKey]  as! TimeInterval
            let options = UIViewAnimationOptions(rawValue:
                (notify!.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                            let deltaY: CGFloat = 0//self.btnInvite.bounds.height
                            self.usersTable.contentInset.bottom = deltaY
                            self.usersTable.scrollIndicatorInsets.bottom = deltaY
                            self.cInviteBottom.constant = 0
                            self.cTitleBottom.constant = 0
                            
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    
}

extension InviteFriendsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.p_filteredNewContacts.count
        case 1:
            return self.p_filteredFriends.count
        default:
            let key = self.p_filteredContactsHeaders![section - 2]
            let users = self.p_filteredContactsDict![key]
            if (users != nil) {
                return users!.count
            }
            break
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.p_filteredContactsHeaders != nil) {
            return self.p_filteredContactsHeaders!.count + 2
        }
        return 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var titles = ["", ""]
        if (self.p_filteredContactsHeaders != nil) {
            titles.append(contentsOf: self.p_filteredContactsHeaders!)
        }
        return titles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InviteFriendsCell
        
        switch indexPath.section {
            
        case 0:
            let newUserName = self.p_filteredNewContacts[indexPath.row]
            cell.nameLabel.text = newUserName
            cell.avatarView.image = UIImage(named: "UserPlaceholder")
            cell.SetSelected(self.isSelected(user: newUserName))
            cell.workoutsLabel.text = ""
            cell.emailsLabel.text = ""
            cell.phonesLabel.text = ""
            cell.isFollowing.isHidden = true
            break
            
        case 1:
            let friend = self.p_filteredFriends[indexPath.row]
            if (!friend.first_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty || !friend.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                cell.nameLabel.text = friend.first_name
                if (!friend.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                    if (!cell.nameLabel.text!.isEmpty) {
                        cell.nameLabel.text! += " "
                    }
                    cell.nameLabel.text! += friend.last_name
                }
            } else if (!friend.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                cell.nameLabel.text = friend.display_name
            } else {
                cell.nameLabel.text = friend.username
            }
            var imageURL = URL(string: friend.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            cell.avatarView.sd_setImage(with: imageURL,
                                        placeholderImage: UIImage(named: "UserPlaceholder"),
                                        options: .allowInvalidSSLCertificates,
                                        completed: nil)
            cell.SetSelected(self.isSelected(user: friend))
            cell.phonesLabel.text = ""
            cell.emailsLabel.text = ""
            cell.workoutsLabel.text = ""
            
            let friendInfo = FriendsManager.shared.FriendWith(nick: cell.nameLabel.text)
            if (friendInfo != nil) {
                WorkoutsManager.shared.GetUserWorkouts(user: friendInfo!, onCompleted: { [weak self, weak cell] (workouts:[WorkoutInfo]) in
                    DispatchQueue.main.async {
                        let visibleCellsPaths = self?.usersTable.indexPathsForVisibleRows
                        if (visibleCellsPaths != nil) {
                            if (visibleCellsPaths!.contains(indexPath)) {
                                if (workouts.count > 1) {
                                    cell?.workoutsLabel.text = "\(workouts.count) Workouts"
                                } else if (workouts.count == 1) {
                                    cell?.workoutsLabel.text = "\(workouts.count) Workout"
                                }
                            }
                        }
                    }
                })
            }
            cell.isFollowing.isHidden = !FriendsManager.shared.following.contains(where: { (userInfo: UserInfo) -> Bool in
                return userInfo.username == friend.username
            })
            break
            
        default:
            let key = self.p_filteredContactsHeaders![indexPath.section - 2]
            let users = self.p_filteredContactsDict![key]
            if (users != nil) {
                let user = users![indexPath.row]
                var name = user.givenName
                if (user.middleName.isEmpty == false) {
                    if (name.isEmpty == false) {
                        name = name + " "
                    }
                    name = name + user.middleName
                }
                if (user.familyName.isEmpty == false) {
                    if (name.isEmpty == false) {
                        name = name + " "
                    }
                    name = name + user.familyName
                }
                cell.nameLabel.text = name
                if (user.thumbnailImageData != nil) {
                    cell.avatarView.image = UIImage(data: user.thumbnailImageData!)
                } else {
                    cell.avatarView.image = UIImage(named: "UserPlaceholder")
                }
                var emails = ""
                for email in user.emailAddresses {
                    if (!email.value.trimmingCharacters(in: .whitespaces).isEmpty) {
                        if (!emails.isEmpty) {
                            emails += ", "
                        }
                        emails += email.value as String
                    }
                }
                cell.emailsLabel.text = emails
                var phones = ""
                for phone in user.phoneNumbers {
                    if (!phone.value.stringValue.trimmingCharacters(in: .whitespaces).isEmpty) {
                        if (!phones.isEmpty) {
                            phones += ", "
                        }
                        phones += phone.value.stringValue
                    }
                }
                cell.phonesLabel.text = phones
                cell.SetSelected(self.isSelected(user: user))
                cell.workoutsLabel.text = ""
                cell.isFollowing.isHidden = true
            } else {
                cell.nameLabel.text = ""
                cell.emailsLabel.text = ""
                cell.phonesLabel.text = ""
                cell.workoutsLabel.text = ""
                cell.avatarView.image = nil
                cell.isFollowing.isHidden = true
            }
            break
        }

        //cell.workoutsLabel.text = "95 Workouts"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension InviteFriendsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            let user = self.p_filteredNewContacts[indexPath.row]
            if (self.isSelected(user: user)) {
                self.deselect(user: user)
            } else {
                self.select(user: user)
            }
            let cell = tableView.cellForRow(at: indexPath) as! InviteFriendsCell
            cell.SetSelected(self.isSelected(user: user))
            break
            
        case 1:
            let user = self.p_filteredFriends[indexPath.row]
            if (self.isSelected(user: user)) {
                self.deselect(user: user)
            } else {
                self.select(user: user)
            }
            let cell = tableView.cellForRow(at: indexPath) as! InviteFriendsCell
            cell.SetSelected(self.isSelected(user: user))
            break
            
        default:
            let key = self.p_filteredContactsHeaders![indexPath.section - 2]
            let users = self.p_filteredContactsDict![key]
            if (users != nil) {
                let user = users![indexPath.row]
                if (self.isSelected(user: user)) {
                    self.deselect(user: user)
                } else {
                    self.select(user: user)
                }
                let cell = tableView.cellForRow(at: indexPath) as! InviteFriendsCell
                cell.SetSelected(self.isSelected(user: user))
            }
            break
        }

    }
}

//MARK: - Search Bar
extension InviteFriendsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.filterContacts(text: searchText)
        
    }
    
 /*   func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        self.filterContacts(text: nil)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }*/
}

//MARK: - Add new user
extension InviteFriendsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            
            // Add new user
            if let text = textField.text {
                let trimmedText = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if (!trimmedText.isEmpty) {
                    self.newContacts.insert(trimmedText, at: 0)
                    self.select(user: trimmedText)
                    
                    self.filterContacts(text: self.searchBar.text)
                }
            }
            
            textField.text = nil
            textField.resignFirstResponder()
            
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.hideNew()
    }
    
}
