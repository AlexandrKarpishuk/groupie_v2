//
//  POST_View.swift
//  groupie
//
//  Created by Sania on 6/11/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import GooglePlaces
import GoogleMaps

class POST_View : UIView {
    
    @IBOutlet weak var btnAvatarView: RoundedButton!
    @IBOutlet weak var whereField: UITextField!
    @IBOutlet weak var whereButton: RoundedButton!
    @IBOutlet weak var whereImage: UIImageView!
    @IBOutlet weak var withWhomField: UITextField!
    @IBOutlet weak var withWhomButton: RoundedButton!
    @IBOutlet weak var withWhomImage: UIImageView!
    @IBOutlet weak var detailsField: UITextField!
    @IBOutlet weak var detailsButton: RoundedButton!
    @IBOutlet weak var postButton: RoundedButton!
    @IBOutlet weak var resultTable: UITableView!
    @IBOutlet weak var friendsTable: UITableView!
    
    @IBOutlet weak var resultTableHeight: NSLayoutConstraint!
    @IBOutlet weak var friendsTableHeight: NSLayoutConstraint!

    fileprivate var placesClient = GMSPlacesClient()
 //   fileprivate var places : [GMSAutocompletePrediction]?
    fileprivate var places : [GMSPlace]?
    fileprivate var friends : [UserInfo]?
    fileprivate let MAX_FRIENDS_COUNT = 4
    fileprivate var p_contactsNumbers = [String]()
    fileprivate var p_contactsEmails = [String]()
    fileprivate var p_contactsNames = [String]()

    fileprivate let CAN_USE_CONTACTS_FOR_AUTOCOMPLETE = false

    var onPostHandler: (()->Void)?
    var onAvatarHandler: (()->Void)?
    
    var isGooglePlace: Bool = false
    var withWhomUsers = [UserInfo]()
    
    @IBAction func onPostPressed() {
        self.whereField.resignFirstResponder()
        self.withWhomField.resignFirstResponder()
        self.detailsField.resignFirstResponder()
        
        self.validateWithWhomUsers()
        
        if (self.onPostHandler != nil) {
            self.onPostHandler!()
        }
        
   /*     self.whereField.text = nil
        self.withWhomField.text = nil
        self.detailsField.text = nil*/
    }
    
    @IBAction func onWherePressed() {
        self.whereField.becomeFirstResponder()
    }
    
    @IBAction func onWhomPressed() {
        self.withWhomField.becomeFirstResponder()
    }
    
    @IBAction func onDetailsPressed() {
        self.detailsField.becomeFirstResponder()
    }
    
    @IBAction func onAvatarPressed() {
        self.validateWithWhomUsers()
        self.onAvatarHandler?()
    }
    
    @IBAction func onAddUserPressed() {
        self.validateWithWhomUsers()
        self.onAvatarHandler?()
    }
    
    @IBAction func onPlacePressed() {
        //self.onLocationUpdated()
        self.whereField.text = LocationManager.shared.currentLocation
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.resultTable.layer.cornerRadius = 3
        
        if let placeholder = self.whereField.placeholder {
            self.whereField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)])
        }
        self.whereField.delegate = self
        self.whereButton.cornerRadius = 8
        
        if let placeholder = self.withWhomField.placeholder {
            self.withWhomField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)])
        }
        self.withWhomField.delegate = self
        self.withWhomButton.cornerRadius = 8
        
        if let placeholder = self.detailsField.placeholder {
            self.detailsField.attributedPlaceholder = NSAttributedString(string:placeholder, attributes: [NSForegroundColorAttributeName: UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)])
        }
        self.detailsButton.cornerRadius = 8
        
        self.postButton.cornerRadius = 10
        
        
        self.whereImage.image = UIImage.fontAwesomeIcon(name: .mapMarker, textColor: UIColor.lightGray, size: CGSize(width: 20, height: 20))
        self.withWhomImage.image = UIImage.fontAwesomeIcon(name: .userPlus, textColor: UIColor.lightGray, size: CGSize(width: 20, height: 20))
        
        self.resultTableHeight.constant = 0
        self.places = nil
        self.friendsTableHeight.constant = 0
        self.friends = nil
        
        let _ = LocationManager.shared // Start watching for user
    }
    
    func loadContacts() {
        DispatchQueue.global().async {
            autoreleasepool(invoking: {
                let contacts = ContactsManager.shared.contacts
                var numbersSet = Set<String>()
                var emailsSet = Set<String>()
                var namesSet = Set<String>()
                for contact in contacts {
                    if (!contact.phoneNumbers.isEmpty) {
                        for phone in contact.phoneNumbers {
                            if (phone.value.stringValue.isPhoneNumber()) {
                                numbersSet.insert(phone.value.stringValue)
                            }
                        }
                    }
                    if (!contact.emailAddresses.isEmpty) {
                        for email in contact.emailAddresses {
                            if ((email.value as String).isEmail()) {
                                emailsSet.insert(email.value as String)
                            }
                        }
                    }
                    namesSet.insert(contact.givenName)
                }
                
                self.p_contactsNumbers = [String]()
                self.p_contactsNumbers.append(contentsOf: numbersSet)
                self.p_contactsEmails = [String]()
                self.p_contactsEmails.append(contentsOf: emailsSet)
                self.p_contactsNames = [String]()
                self.p_contactsNames.append(contentsOf: namesSet)
            })
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if (newSuperview == nil) {
            NotificationCenter.default.removeObserver(self)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(onLocationUpdated), name: NSNotification.Name(rawValue: LocationManager.LOCATION_UPDATED_NOTIFICATION), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onLogout), name: ServerManager.LOGGED_OUT_NOTIFICATION, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onLogin), name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
        }
    }
    
    @objc func onLogin() {
        if (ServerManager.shared.currentUser != nil) {
            var imageURL = URL(string: ServerManager.shared.currentUser!.profile_picture_url)
            if (imageURL == nil) {
                imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
            }
            self.btnAvatarView.sd_setBackgroundImage(with: imageURL, for: .normal,
                                                     placeholderImage: UIImage(named: "UserPlaceholder"),
                                                     options: .allowInvalidSSLCertificates,
                                                     completed: nil)
        }
    }
    @objc func onLogout() {
        let imageURL =  Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
        self.btnAvatarView.sd_setBackgroundImage(with: imageURL, for: .normal,
                                                 placeholderImage: UIImage(named: "UserPlaceholder"),
                                                 options: .allowInvalidSSLCertificates,
                                                 completed: nil)
    }
    
    func onLocationUpdated() {
     /*   if (self.whereField.text == nil || self.whereField.text!.isEmpty) {
            self.whereField.text = LocationManager.shared.currentLocation
        }*/
    }
    
    func willShow() {
        self.hideAutoWindows()
        
        self.btnAvatarView.cornerRadius = self.btnAvatarView.bounds.height * 0.49
        if (ServerManager.shared.currentUser != nil) {
            let imageURL = URL(string: ServerManager.shared.currentUser!.profile_picture_url)
            self.btnAvatarView.sd_setBackgroundImage(with: imageURL, for: .normal,
                                        placeholderImage: UIImage(named: "UserPlaceholder"),
                                        options: .allowInvalidSSLCertificates,
                                        completed: nil)
        }
        self.loadContacts()
    }
    
    func willHide() {
        self.hideAutoWindows()
    }
    
    func hideAutoWindows() {
        self.resultTableHeight.constant = 0
        self.places = nil
        self.resultTable.reloadData()
        
        self.friendsTableHeight.constant = 0
        self.friends = nil
        self.friendsTable.reloadData()
    }
}

extension POST_View : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == self.whereField) {
      //      self.whereField.resignFirstResponder()
      //      self.withWhomField.becomeFirstResponder()
            self.places = nil
            self.resultTableHeight.constant = 0
            self.resultTable.reloadData()
        } else if (textField == self.withWhomField) {
       //     self.withWhomField.resignFirstResponder()
       //     self.detailsField.becomeFirstResponder()
            self.friends = nil
            self.friendsTableHeight.constant = 0
            self.friendsTable.reloadData()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.whereField) {
            self.friends = nil
            self.friendsTableHeight.constant = 0
            self.friendsTable.reloadData()
        } else if (textField == self.withWhomField) {
            self.places = nil
            self.resultTableHeight.constant = 0
            self.resultTable.reloadData()
        } else {
            self.places = nil
            self.resultTableHeight.constant = 0
            self.resultTable.reloadData()
            self.friends = nil
            self.friendsTableHeight.constant = 0
            self.friendsTable.reloadData()
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.withWhomUsers = [UserInfo]()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string == "\n") {
            if (textField == self.whereField) {
                self.whereField.resignFirstResponder()
                self.withWhomField.becomeFirstResponder()
                self.places = nil
                self.resultTableHeight.constant = 0
                self.resultTable.reloadData()
                return false
            } else if (textField == self.withWhomField) {
                self.withWhomField.resignFirstResponder()
                self.detailsField.becomeFirstResponder()
                self.friends = nil
                self.friendsTableHeight.constant = 0
                self.friendsTable.reloadData()
                return false
            } else {
                self.hideAutoWindows()
                self.onPostPressed()
                return false
            }
        } else {
            if (textField == self.whereField) {
                var returnVal = true
                let from = textField.text?.index(textField.text!.startIndex, offsetBy: range.location)
                let to = textField.text?.index(from!, offsetBy: range.length)
                let newText = textField.text?.replacingCharacters(in: from!..<to!, with: string)
                if (textField.attributedText != nil && newText != nil) {
                    let newAttrText = NSAttributedString(string: newText!, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: textField.font!.pointSize)])
                    textField.attributedText = newAttrText
                    returnVal = false
                    self.isGooglePlace = false
                }
                if (newText!.count > 0) {
                    let filter = GMSAutocompleteFilter()
                    filter.type = .noFilter//.establishment
                    filter.country = "US"
                    let gmsPath = GMSMutablePath()
                    gmsPath.addLatitude(32.501340, longitude: -117.803803)
                    gmsPath.addLatitude(49.4287500, longitude: -177.7171407)
                    gmsPath.addLatitude(71.878410, longitude: -166.642923)
                    gmsPath.addLatitude(70.605599, longitude: -141.055110)
                    gmsPath.addLatitude(60.362371, longitude:-141.149974)
                    gmsPath.addLatitude(60.324066, longitude: -139.094763)
                    gmsPath.addLatitude(58.813036, longitude: -137.280645)
                    gmsPath.addLatitude(59.654834, longitude: -135.497768)
                    gmsPath.addLatitude(55.815523, longitude: -130.149137)
                    gmsPath.addLatitude(49.242268, longitude: -129.337346)
                    gmsPath.addLatitude(48.988262, longitude: -93.091623)
                    gmsPath.addLatitude(46.590159, longitude: -83.933171)
                    gmsPath.addLatitude(41.924501, longitude: -82.536120)
                    gmsPath.addLatitude(47.594101, longitude: -68.643220)
                    gmsPath.addLatitude(27.436356, longitude: -62.133458)
                    gmsPath.addLatitude(21.466612, longitude: -74.519231)
                    gmsPath.addLatitude(25.844556, longitude: -97.218141)
                    gmsPath.addLatitude(31.501890, longitude: -106.594786)
                    gmsPath.add(CLLocationCoordinate2D(latitude:32.501340, longitude: -117.803803))
                    let gmsBounds = GMSCoordinateBounds(path: gmsPath)
                    NSLog("IsValid \(gmsBounds.isValid)")
                    placesClient.autocompleteQuery(newText!, bounds: gmsBounds, filter: filter, callback: { (complete:[GMSAutocompletePrediction]?, error:Error?) in
                        //<#T##GMSCoordinateBounds?#>
                        if (error != nil) {
                            NSLog("Places Error: \(error!)")
                            DispatchQueue.main.async {
                                // self.places = complete
                                self.places = nil
                                self.resultTableHeight.constant = 0
                                self.resultTable.reloadData()
                                
                            }
                        } else if let retainedComlete = complete {
                            DispatchQueue.global().async {
                                let dispatchGroup = DispatchGroup()
                                var newPlaces = [GMSPlace]()
                                for place in retainedComlete {
                                    dispatchGroup.enter()
                                    self.placesClient.lookUpPlaceID(place.placeID!, callback: { (res:GMSPlace?, error:Error?) in
                                        //    NSLog("Name: '\(res!.name)' Address: '\(res!.formattedAddress!)'")
                                        if (res != nil && error == nil) {
                                            newPlaces.append(res!)
                                        }
                                        dispatchGroup.leave()
                                    })
                                }
                                dispatchGroup.wait(wallTimeout: DispatchWallTime.now() + 15.0)
                                
                                var placeDict = [String: GMSPlace]()
                                for place in newPlaces {
                                    if (gmsBounds.contains(place.coordinate)) {
                                        placeDict[self.getPlaceName(place)] = place
                                    }
                                }
                                var result = [GMSPlace]()
                                for place in placeDict.values {
                                    result.append(place)
                                }
                                
                                
                                DispatchQueue.main.async {
                                    // self.places = complete
                                    if (self.whereField.isFirstResponder) {
                                        self.places = result//newPlaces
                                        if (self.places != nil) {
                                            self.resultTableHeight.constant = CGFloat(25 * self.places!.count)
                                        } else {
                                            self.resultTableHeight.constant = 0
                                        }
                                        self.resultTable.reloadData()
                                    }
                                }
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        // self.places = complete
                        self.places = nil
                        if (self.places != nil) {
                            self.resultTableHeight.constant = CGFloat(25 * self.places!.count)
                        } else {
                            self.resultTableHeight.constant = 0
                        }
                        self.resultTable.reloadData()
                        
                    }
                }
                return returnVal
            } else if (textField == self.withWhomField) {
                let from = textField.text?.index(textField.text!.startIndex, offsetBy: range.location)
                let to = textField.text?.index(from!, offsetBy: range.length)
                var newText = textField.text?.replacingCharacters(in: from!..<to!, with: string)
                let components = newText?.components(separatedBy: CharacterSet(charactersIn:","))
                if (components != nil && components!.count > 0) {
                    newText = components!.last!.trimmingCharacters(in: CharacterSet(charactersIn: " "))
                }
                if (newText!.count > 0) {
                    DispatchQueue.global().async {
                        var tmpFriends = FriendsManager.shared.followers
                        tmpFriends.append(contentsOf: FriendsManager.shared.following)
                        ServerManager.shared.SearchUsers(request: newText, onSuccess: { [weak self] (users:[UserInfo]) in
                                if let strongSelf = self {
                                    tmpFriends.append(contentsOf: users)
                                    strongSelf.processAutocompleteUsers(tmpFriends, newText: newText!)
                                }
                            }, onFail: { [weak self] (message:String?) in
                                if let strongSelf = self {
                                    strongSelf.processAutocompleteUsers(tmpFriends, newText: newText!)
                                }
                        })
                    }
                } else {
                    self.friends = nil
                    self.friendsTableHeight.constant = 0
                    self.friendsTable.reloadData()
                }
            }
        }
        return true
    }

    
    fileprivate func processAutocompleteUsers(_ tmpFriends: [UserInfo], newText: String) {
        var result = [UserInfo]()
        for user in tmpFriends {
            let userFullName = self.userFullName(user)
            if (userFullName.range(of: newText, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
                var isFriendAvailable = false
                for savedFriend in result {
                    if (savedFriend.username == user.username) {
                        isFriendAvailable = true
                        break
                    }
                }
                if (!isFriendAvailable) {
                    result.append(user)
                    if (result.count >= self.MAX_FRIENDS_COUNT) {
                        break
                    }
                }
            }
        }
        
/*        if (self.CAN_USE_CONTACTS_FOR_AUTOCOMPLETE
            && result.count < self.MAX_FRIENDS_COUNT) {
            if (newText.isPhoneNumber()) {
                var phoneText = newText
                while let tmpRange = phoneText.rangeOfCharacter(from: CharacterSet(charactersIn:" +()-")) {
                    phoneText.removeSubrange(tmpRange)
                }
                for phoneNumber in self.p_contactsNumbers {
                    if (phoneNumber.getPhoneNumber().range(of: phoneText, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
                        var isFriendAvailable = false
                        for savedFriend in result {
                            if (savedFriend == phoneNumber) {
                                isFriendAvailable = true
                                break
                            }
                        }
                        if (!isFriendAvailable) {
                            result.append(phoneNumber)
                            if (result.count >= self.MAX_FRIENDS_COUNT) {
                                break
                            }
                        }
                    }
                }
            } else {
                for email in self.p_contactsEmails {
                    if (email.range(of: newText, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
                        var isFriendAvailable = false
                        for savedFriend in result {
                            if (savedFriend == email) {
                                isFriendAvailable = true
                                break
                            }
                        }
                        if (!isFriendAvailable) {
                            result.append(email)
                            if (result.count >= self.MAX_FRIENDS_COUNT) {
                                break
                            }
                        }
                    }
                }
                if (result.count < self.MAX_FRIENDS_COUNT) {
                    for name in self.p_contactsNames {
                        if (name.range(of: newText, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
                            var isFriendAvailable = false
                            for savedFriend in result {
                                if (savedFriend == name) {
                                    isFriendAvailable = true
                                    break
                                }
                            }
                            if (!isFriendAvailable) {
                                result.append(name)
                                if (result.count >= self.MAX_FRIENDS_COUNT) {
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }*/
        
        
        
        DispatchQueue.main.async {
            if (self.withWhomField.isFirstResponder) {
                self.friends = result
                if (self.friends != nil) {
                    self.friendsTableHeight.constant = CGFloat(25 * self.tableView(self.friendsTable, numberOfRowsInSection: 0))
                } else {
                    self.friendsTableHeight.constant = 0
                }
                self.friendsTable.reloadData()
            }
        }
    }
    
}



extension POST_View : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == self.resultTable) {
            if (self.places != nil) {
                return self.places!.count
            }
        } else if (tableView == self.friendsTable) {
            if (self.friends != nil) {
                return self.friends!.count + 1
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (tableView == self.resultTable) {
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! POST_View_Cell
            let place = self.places![indexPath.row]
 /*           cell.titleLabel.attributedText = place.attributedPrimaryText
            NSLog("Primary: \(place.attributedPrimaryText)")
            NSLog("Second: \(place.attributedSecondaryText)")
            NSLog("Full: \(place.attributedFullText)")*/
            (cell as! POST_View_Cell).titleLabel.text = self.getPlaceName(place)
        } else if (tableView == self.friendsTable) {
            if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1) {
                cell = tableView.dequeueReusableCell(withIdentifier: "Cell Add", for: indexPath)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! POST_View_Cell
                let friend = self.friends![indexPath.row]
                (cell as! POST_View_Cell).titleLabel.text = self.userFullName(friend)
                (cell as! POST_View_Cell).isFollowing?.isHidden = !FriendsManager.shared.following.contains(where: { (user: UserInfo) -> Bool in
                    return user.username == friend.username
                })
            }


        }
        return cell!
    }
    
    fileprivate func getPlaceName(_ place: GMSPlace) -> String {
        var placeStr = place.name
        let keys = ["street_number", "route", "locality", "country"]
        var address = ""
        for addressItem in place.addressComponents! {
            NSLog("Type: \(addressItem.type) name: \(addressItem.name)")
        }
        for key in keys {
            for addressItem in place.addressComponents! {
                if (key == addressItem.type) {
                    if (!address.isEmpty) {
                        if (key == "route") {
                            address += " "
                        } else {
                            address += ", "
                        }
                    }
                    address += addressItem.name
                    break
                }
            }
        }
        if (!placeStr.isEmpty && !address.isEmpty) {
            placeStr += " - "
        }
        placeStr += address
        return placeStr
    }
}

extension POST_View : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.resultTable) {
            let place = self.places![indexPath.row]
          //  self.whereField.attributedText = place.attributedPrimaryText
            self.whereField.text = self.getPlaceName(place)
            self.whereField.attributedText = NSAttributedString(string: self.whereField.text!, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: self.whereField.font!.pointSize)])
            self.isGooglePlace = true
            self.places = nil
            self.resultTableHeight.constant = 0
            self.resultTable.reloadData()
        } else if (tableView == self.friendsTable) {
            if (indexPath.row == self.tableView(tableView, numberOfRowsInSection: 0) - 1) {
                self.onAddUserPressed()
            } else {
                let friend = self.friends![indexPath.row]
                self.validateWithWhomUsers()
                self.withWhomUsers.append(friend)
                self.showWithWhomUsers()
                self.friends = nil
                self.friendsTableHeight.constant = 0
                self.friendsTable.reloadData()
            }
        }
    }
    
    func showWithWhomUsers() {
        var newText = ""
        for user in self.withWhomUsers {
            let userName = self.userFullName(user)
            if (!userName.isEmpty) {
                if (!newText.isEmpty) {
                    newText += ", "
                }
                newText += userName
            }
        }
        self.withWhomField.text = newText
    }
    
    func validateWithWhomUsers() {
        var newWithWhomUsers = [UserInfo]()
        for user in self.withWhomUsers {
            let userName = self.userFullName(user)
            if (!userName.isEmpty && self.withWhomField.text != nil) {
                if (self.withWhomField.text?.range(of: userName) != nil) {
                    newWithWhomUsers.append(user)
                }
            }
        }
        self.withWhomUsers = newWithWhomUsers
        self.showWithWhomUsers()
    }
    
    fileprivate func userFullName(_ user: UserInfo) -> String {
        var userFullName = ""
        if (!user.first_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty || !user.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
            userFullName = user.first_name
            if (!user.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                if (!userFullName.isEmpty) {
                    userFullName += " "
                }
                userFullName += user.last_name
            }
        } else if (!user.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
            userFullName = user.display_name
        } else {
            userFullName = user.username
        }
        return userFullName
    }
}
