//
//  SearchFriendsVC.swift
//  groupie
//
//  Created by Sania on 6/15/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

import Contacts
import SDWebImage

class SearchFriendsVC: GroupieViewController {
    
    @IBOutlet weak var usersTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var emptyViewBottom: NSLayoutConstraint!
    
    fileprivate var p_contacts: [CNContact]?
    fileprivate var p_filteredContactsDict: [String: [CNContact]]?
    fileprivate var p_filteredContactsHeaders: [String]?

    fileprivate var p_users = [UserInfo]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

  //      self.title = "Search Friends"
  //      self.usersTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    /*    self.navigationController?.navigationBar.topItem?.title = "Search Friends"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]*/
    //    self.loadData()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onContactsUpdated), name: ContactsManager.CONTACTS_LOADED_NOTIFICATION, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
     /*   if (self.searchBar.text == nil || self.searchBar.text!.isEmpty) {
            self.showEmptyView(animated: false)
        } else {*/
            self.loadData(request: self.searchBar.text)
     //   }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    public func onContactsUpdated() {
 //       self.loadData()
    }
    
    public func loadData(request: String?) {
     //   let newContacts = ContactsManager.shared.contacts
//        let oldContacts = self.p_contacts
        // parse new contacts
        
      //  self.p_contacts = newContacts
        if (request == nil || request!.isEmpty) {
            self.p_users = FriendsManager.shared.following
            self.usersTable.reloadData()
            if (self.tableView(self.usersTable, numberOfRowsInSection: 0) == 0) {
                self.showEmptyView(animated: true)
            } else {
                self.hideEmptyView(animated: true)
            }
        } else {
            ServerManager.shared.SearchUsers(request: request, onSuccess: { [weak self] (users:[UserInfo]) in
                if let strongSelf = self {
                    strongSelf.p_users = users
                    strongSelf.usersTable.reloadData()
                    if (strongSelf.tableView(strongSelf.usersTable, numberOfRowsInSection: 0) == 0) {
                        strongSelf.showEmptyView(animated: true)
                    } else {
                        strongSelf.hideEmptyView(animated: true)
                    }
                }
       //         self.filterContacts(text: self.searchBar.text)
            }, onFail: { [weak self] (message:String?) in
                let alert = UIAlertController(title: "Attention",
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: UIAlertActionStyle.cancel,
                                              handler:nil))
                self?.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    fileprivate func filterContacts(text: String?) {
        var contacts = self.p_contacts
        
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
            }
        }
        
        self.p_filteredContactsDict = [String: [CNContact]]()
        for contact in contacts! {
            if (contact.givenName.characters.count > 0) {
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
        
        self.usersTable.reloadData()
        if (self.tableView(self.usersTable, numberOfRowsInSection: 0) == 0) {
            self.showEmptyView(animated: true)
        } else {
            self.hideEmptyView(animated: true)
        }
    }
    
    fileprivate func showEmptyView(animated: Bool = true) {
        if (animated) {
            UIView.animate(withDuration: 0.3) {
                self.emptyView.alpha = 1.0
            }
        } else {
            self.emptyView.alpha = 1.0
        }
    }
    
    fileprivate func hideEmptyView(animated: Bool = true) {
        if (animated) {
            UIView.animate(withDuration: 0.3) {
                self.emptyView.alpha = 0.0
            }
        } else {
            self.emptyView.alpha = 0.0
        }
    }
}

extension SearchFriendsVC /* Keyboard */ {
    
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
                            self.usersTable.contentInset.bottom = endFrame.height
                            self.usersTable.scrollIndicatorInsets.bottom = endFrame.height
                            self.emptyViewBottom.constant = endFrame.height
                            self.view.layoutIfNeeded()
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
                            self.usersTable.contentInset.bottom = 0
                            self.usersTable.scrollIndicatorInsets.bottom = 0
                            self.emptyViewBottom.constant = 0
                            
                            self.view.layoutIfNeeded()
                            
            }, completion: { (Bool) in
                
            })
        }
    }

    
}

extension SearchFriendsVC : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.p_filteredContactsHeaders != nil) {
            let key = self.p_filteredContactsHeaders![section]
            let users = self.p_filteredContactsDict![key]
            if (users != nil) {
                return users!.count
            }
        } else {
            return self.p_users.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (self.p_filteredContactsHeaders != nil) {
            return self.p_filteredContactsHeaders!.count
        }
        return 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if (self.p_filteredContactsHeaders != nil) {
            return self.p_filteredContactsHeaders
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchFriendsCell
        
        if (self.p_filteredContactsHeaders != nil) {
            let key = self.p_filteredContactsHeaders![indexPath.section]
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
                    cell.avatarView.image = nil
                }
            } else {
                cell.nameLabel.text = ""
                cell.avatarView.image = nil
            }
            cell.workoutsLabel.text = ""
            
            let friend = FriendsManager.shared.FriendWith(nick: cell.nameLabel.text)
            if (friend != nil) {
                WorkoutsManager.shared.GetUserWorkouts(user: friend!, onCompleted: { (workouts:[WorkoutInfo]) in
                    DispatchQueue.main.async {
                        let visibleCellsPaths = self.usersTable.indexPathsForVisibleRows
                        if (visibleCellsPaths != nil) {
                            if (visibleCellsPaths!.contains(indexPath)) {
                                if (workouts.count > 1) {
                                    cell.workoutsLabel.text = "\(workouts.count) Workouts"
                                } else if (workouts.count == 1) {
                                    cell.workoutsLabel.text = "\(workouts.count) Workout"
                                }
                            }
                        }
                    }
                })
                cell.isFollowing.isHidden = !FriendsManager.shared.following.contains(where: { (userInfo: UserInfo) -> Bool in
                    return userInfo.username == friend!.username
                })
            } else {
                cell.isFollowing.isHidden = true
            }

        } else {
            let info = self.p_users[indexPath.row]
            if (!info.first_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty || !info.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                cell.nameLabel.text = info.first_name
                if (!info.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                    if (!cell.nameLabel.text!.isEmpty) {
                        cell.nameLabel.text! += " "
                    }
                    cell.nameLabel.text! += info.last_name
                }
            } else if (!info.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                cell.nameLabel.text = info.display_name
            } else {
                cell.nameLabel.text = info.username
            }
            cell.avatarView.image = nil
            cell.workoutsLabel.text = ""

       //     NSLog("\(info.profile_picture_url)")
            var imageURL = URL(string: info.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            cell.avatarView.sd_setImage(with: imageURL,
                                        placeholderImage: UIImage(named: "UserPlaceholder"),
                                        options: .allowInvalidSSLCertificates,
                                        completed: nil)
            
            WorkoutsManager.shared.GetUserWorkouts(user: info, onCompleted: { [weak self, weak cell] (workouts:[WorkoutInfo]) in
                DispatchQueue.main.async { [weak self, weak cell] in
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
            cell.isFollowing.isHidden = !FriendsManager.shared.following.contains(where: { (userInfo: UserInfo) -> Bool in
                return userInfo.username == info.username
            })
        }
        //cell.workoutsLabel.text = "95 Workouts"

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
}

extension SearchFriendsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user = self.p_users[indexPath.row]
        WorkoutsManager.shared.GetUserWorkouts(user: user, onCompleted: { [weak self] (workouts:[WorkoutInfo]) in
            
            DispatchQueue.main.async { [weak self] in
                if let profileVC = self?.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? ProfileVC {
                    profileVC.user = user
                    profileVC.workouts = workouts
                    (self?.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(profileVC, animated: true)
                }
                self?.view.hideActivity()
            }
        })
    }
    
/*    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
 //       if let workoutCell = cell as? SearchFriendsCell {
//            workoutCell.avatarView.sd_cancelCurrentImageLoad()
 //       }
    }*/
}

extension SearchFriendsVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadData(request: self.searchBar.text)
        //self.filterContacts(text: searchText)
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
