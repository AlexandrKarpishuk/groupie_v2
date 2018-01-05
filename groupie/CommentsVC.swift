//
//  CommentsVC.swift
//  groupie
//
//  Created by Sania on 7/5/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class CommentsVC: UIViewController {
    
    fileprivate struct TagInfo {
        var info : UserInfo?
        var range : NSRange?
    }
    
    fileprivate let comments = ["Hi Jeff!", "People in Great Britain like animals. There are even special hospitals, which help wild animals. There are a lot of television films about wildlife. They are very popular with children and grown ups. A lot of British families have ‘bird tables’ in their gardens. Birds can eat from them during the winter months. The ‘bird table’ should be high because cats can eat birds.", "The British often think their animals are like people. For example in Britain animals can have jobs like people. British Rail has cats and pays them for their work. Their job is to catch mice. There is usually one cat per station. They get food and free medical help. The cats don’t catch a lot of mice but they are very popular with the British Rail staff and travellers.", "I’m really interested in astronomy and space — I want to become an astronaut. When I was in London some weeks ago, I had the best day in my life. I met Helen Sharman, the first British astronaut. She gave a talk in London. After the talk my mum asked the steward and he allowed me to meet Helen Sharman. She was really nice and I got her autograph. When I went home, I wrote a letter to her. I hope to get her answer soon. Love Jenny Austin"]
    fileprivate let opponents = ["Sania", "Someone", "Someone", "Jenny Austin"]
    fileprivate let time = ["1h", "45s", "12s", "1s"]
    
    public var workout: WorkoutInfo?
    fileprivate var p_comments: [CommentInfo]?
    
    @IBOutlet var commentsTable: CommentsTable!
    @IBOutlet var emptyView: UIView!
    
    fileprivate var friendsTable: UITableView?
    fileprivate var friendsTableHeight: NSLayoutConstraint?
//    fileprivate var inputViewHeight: NSLayoutConstraint?
    
    fileprivate var p_textFieldRightConstraint: NSLayoutConstraint?
    fileprivate var p_btnSendWidthConstraint: NSLayoutConstraint?
    fileprivate var p_btnSendHeightConstraint: NSLayoutConstraint?
    
    fileprivate var observerContext = 0
    fileprivate let BTN_SEND_WIDTH:CGFloat = 60
    fileprivate let BTN_SEND_HEIGHT:CGFloat = 34
    fileprivate var p_textField: UITextField?
    fileprivate var p_btnSend: RoundedButton?
    fileprivate var p_keyboardHeight: CGFloat = 0
    fileprivate var p_sendFontSize: CGFloat = 0
    
    fileprivate var p_textView: UITextView?
    fileprivate var p_textBottomSpace: CGFloat = 0
    fileprivate let MAX_FRIENDS_COUNT: Int = 5
    
    fileprivate var friends : [UserInfo]?
    fileprivate var p_contactsNumbers = [String]()
    fileprivate var p_contactsEmails = [String]()
    fileprivate var p_contactsNames = [String]()
    fileprivate var p_taggedUserNames = Set<String>()
    fileprivate var p_taggedUsers = [TagInfo]()
    
    fileprivate var updateTimer: Timer?
    fileprivate var p_isWorkoutsLoadingInProgress = false
    fileprivate var p_savedInputText: String?
    
    fileprivate var p_users = [String: UserInfo]()
    
    fileprivate let USE_NEW_USER_INVITED = true

    fileprivate var p_bottomBar: CommentInputView {
        get {
            if (self.p_inputView == nil) {
                self.p_inputView = CommentInputView()
                self.p_inputView?.backgroundColor = UIColor(white: 238.0/255.0, alpha: 1.0)
                self.p_inputView?.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
             //   inputView.translatesAutoresizingMaskIntoConstraints = true
                self.p_inputView?.frame = CGRect(x: 0,
                                        y: 0,
                                        width: self.view.bounds.width,
                                        height: 44)
                self.p_inputView?.customHeight = 44
                self.p_inputView?.isUserInteractionEnabled = true
            //    inputView.setNeedsLayout()
            //    inputView.layoutIfNeeded()
         //       NSLog("test: \(inputView.constraints)")
                
                self.p_btnSend = RoundedButton(type: UIButtonType.custom)
                self.p_btnSend!.frame = CGRect(x: self.view.bounds.width - 8 - self.BTN_SEND_WIDTH,
                                              y: 5,
                                              width: self.BTN_SEND_WIDTH,
                                              height: self.BTN_SEND_HEIGHT)
                self.p_btnSend!.backgroundColor = UIColor(red: 101.0 / 255.0,
                                                          green: 189.0 / 255.0,
                                                          blue: 43.0 / 255.0,
                                                          alpha: 1.0)
                self.p_btnSend!.titleLabel!.textColor = UIColor(white: 1.0, alpha: 0.4)
                self.p_btnSend!.setTitle("Send", for: .normal)
                self.p_btnSend!.cornerRadius = 5
                self.p_btnSend!.translatesAutoresizingMaskIntoConstraints = false
                self.p_btnSend!.addTarget(self, action: #selector(onSend), for:.touchUpInside)
                self.p_sendFontSize = self.p_btnSend!.titleLabel!.font.pointSize
                self.p_inputView?.addSubview(self.p_btnSend!)
                
                self.friendsTable = UITableView(frame: CGRect(x:0, y:0, width: self.view.bounds.width, height:0))
                self.friendsTable?.register(UINib.init(nibName: "AutocompleteCell", bundle: nil), forCellReuseIdentifier: "Cell")
                self.friendsTable!.translatesAutoresizingMaskIntoConstraints = false
                self.friendsTable!.dataSource = self
                self.friendsTable!.delegate = self
                self.friendsTable!.rowHeight = UITableViewAutomaticDimension
                self.friendsTable!.estimatedRowHeight = 24.5
                self.friendsTable!.isUserInteractionEnabled = true
                self.p_inputView?.addSubview(self.friendsTable!)
                
                
                self.p_textField = UITextField(frame: CGRect(x: 8,
                                                             y: 7,
                                                             width: self.p_btnSend!.bounds.minX - 8 - 8,
                                                             height: 30))
                self.p_textField!.placeholder = "Add comment or tag a user with '@'"
                self.p_textField!.translatesAutoresizingMaskIntoConstraints = false
                self.p_textField!.borderStyle = .roundedRect
                self.p_textField!.backgroundColor = .white
                self.p_textField!.delegate = self
                self.p_textField!.addObserver(self, forKeyPath: "selectedTextRange", options: NSKeyValueObservingOptions(), context: nil)

                self.p_inputView?.addSubview(self.p_textField!)
                
                var constraints = [NSLayoutConstraint]()
                
            /*    self.inputViewHeight = NSLayoutConstraint(item: inputView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44)
                */
             //   constraints += [self.inputViewHeight!]
                
                let horizontalTable = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[table]-0-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["table": self.friendsTable!])
                constraints += horizontalTable
                let top = NSLayoutConstraint(item: self.friendsTable!, attribute: .top, relatedBy: .equal, toItem: self.p_inputView, attribute: .top, multiplier: 1, constant: 0)
                let bottom = NSLayoutConstraint(item: self.friendsTable!, attribute: .bottom, relatedBy: .equal, toItem: self.p_inputView!, attribute: .bottom, multiplier: 1, constant: 44)
                constraints += [/*bottom,*/ top]
                self.friendsTableHeight = NSLayoutConstraint(item: self.friendsTable!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
                constraints += [self.friendsTableHeight!]
                
                let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[TextField]", options: NSLayoutFormatOptions(), metrics: [:], views: ["TextField" : self.p_textField!])
                constraints += horizontal
                self.p_textFieldRightConstraint = NSLayoutConstraint(item: self.p_inputView!,
                                                  attribute: NSLayoutAttribute.right,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: self.p_textField!,
                                                  attribute: NSLayoutAttribute.right,
                                                  multiplier: 1,
                                                  constant: 8)
                constraints += [self.p_textFieldRightConstraint!]
                
                constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[btnSend]-8-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["btnSend" : self.p_btnSend!])
                
                self.p_btnSendWidthConstraint = NSLayoutConstraint(item: self.p_btnSend!,
                                                                   attribute: NSLayoutAttribute.width,
                                                                   relatedBy: NSLayoutRelation.equal,
                                                                   toItem: nil,
                                                                   attribute: NSLayoutAttribute.notAnAttribute,
                                                                   multiplier: 1,
                                                                   constant: 0)
                constraints += [self.p_btnSendWidthConstraint!]
                
                let verticalTextField = NSLayoutConstraint.constraints(withVisualFormat: "V:[TextField(30)]-7-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["TextField" : self.p_textField!])
                constraints += verticalTextField
           /*     let verticalBtnSend = NSLayoutConstraint.constraints(withVisualFormat: "V:|-5-[btnSend]-5-|", options: NSLayoutFormatOptions(), metrics: [:], views: ["btnSend" : self.p_btnSend!])
                constraints += verticalBtnSend*/
                
                self.p_btnSendHeightConstraint = NSLayoutConstraint(item: self.p_btnSend!,
                                                                   attribute: NSLayoutAttribute.height,
                                                                   relatedBy: NSLayoutRelation.equal,
                                                                   toItem: nil,
                                                                   attribute: NSLayoutAttribute.notAnAttribute,
                                                                   multiplier: 1,
                                                                   constant: 0)
                constraints += [self.p_btnSendHeightConstraint!]

                let center = NSLayoutConstraint(item: self.p_btnSend!,
                                                attribute: NSLayoutAttribute.centerY,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: self.p_textField!,
                                                attribute: NSLayoutAttribute.centerY,
                                                multiplier: 1,
                                                constant: 0)
                constraints += [center]

                
                NSLayoutConstraint.activate(constraints)
                UIView.animate(withDuration: 0, animations: {
                    self.view.layoutIfNeeded()
                })
            }
            return self.p_inputView!
        }
    }
    
    fileprivate var p_inputView: CommentInputView?
  /*  override var inputAccessoryViewController: UIInputViewController? { get {
        let inputVC = self.storyboard?.instantiateViewController(withIdentifier: "CommentsInputVC") as? CommentsInputController
        NSLog("Bounds: \(String(describing: inputVC?.view.bounds))")
        self.view.setNeedsUpdateConstraints()
        return inputVC
        }
    }*/
    override var inputAccessoryView: UIView? { get {
        return self.p_bottomBar
        }
    }
    
    override var canBecomeFirstResponder: Bool { get {
        return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.commentsTable?.rowHeight = UITableViewAutomaticDimension
        self.commentsTable?.estimatedRowHeight = 180
    }
    
    @IBAction func onTagPressed() {
        let inviteFriendVC = self.storyboard!.instantiateViewController(withIdentifier: "inviteFriendsVC") as? InviteFriendsVC
        
        if (inviteFriendVC != nil) {
            inviteFriendVC!.canShowFriends = true
            inviteFriendVC!.canShowContacts = false
            inviteFriendVC!.onInviteHandler = { [weak self] (selected: [UserInfo]) in
                
                if let strongSelf = self {
                    if (selected.count > 0) {
                        let height = strongSelf.p_bottomBar.customHeight
                        NSLog("\(height)")
                        var newText = strongSelf.p_savedInputText// strongSelf.p_textView!.text
                        if newText == nil {
                            newText = ""
                        }
                        for user in selected {
                            if (user is String) {
                                let newUser = UserInfo(info: nil)
                                newUser.username = user as! String
                                var newTag = TagInfo(info: newUser, range: nil)
                                var newRange = NSRange()
                                newRange.location = newText!.count
                                if (strongSelf.USE_NEW_USER_INVITED) {
                                    newRange.length = "*New user invited".count + 1
                                    newText! += "@*New user invited "
                                } else {
                                    newRange.length = (user as! String).count + 1
                                    newText! += "@\(user as! String) "
                                }
                                newTag.range = newRange
                                strongSelf.p_taggedUsers.append(newTag)
                            } else if (user is UserInfo) {
                                let newUser = (user as! UserInfo)
                                var newTag = TagInfo(info: newUser, range: nil)
                                var newRange = NSRange()
                                newRange.location = newText!.count
                                let fullName = strongSelf.userFullName(user as! UserInfo)
                                newRange.length = fullName.count + 1
                                newText! += "@\(fullName) "
                                newTag.range = newRange
                                strongSelf.p_taggedUsers.append(newTag)
                            }
                        }
                        strongSelf.p_textField!.text = newText
                        let attrStr = NSMutableAttributedString(string: newText!)
                        
                        for taggedFriend in strongSelf.p_taggedUsers {
                            attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:taggedFriend.range!)
                        }
                        strongSelf.p_textField!.attributedText = attrStr
                    } else {
                        var newText = strongSelf.p_savedInputText
                        if (newText == nil) {
                            newText = ""
                        }
                        strongSelf.p_textField!.text = newText
                        let attrStr = NSMutableAttributedString(string: newText!)
                        
                        for taggedFriend in strongSelf.p_taggedUsers {
                            attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:taggedFriend.range!)
                        }
                        strongSelf.p_textField!.attributedText = attrStr
                    }
                }
                inviteFriendVC?.navigationController?.popViewController(animated: true)
                
            }
            inviteFriendVC!.onBackHandler = {
                inviteFriendVC?.navigationController?.popViewController(animated: true)
            }
            (self.slideMenuController()?.mainViewController as? UINavigationController)?.pushViewController(inviteFriendVC!, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let icon = UIImage.fontAwesomeIcon(name: .userPlus, textColor: .white, size: CGSize(width: 24, height: 24))//UIImage(named: "PlusButton")!
        let tagButton = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.onTagPressed))
        tagButton.tintColor = .lightGray
        self.navigationItem.rightBarButtonItem = tagButton
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillChangeFrame), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.navigationController?.navigationBar.tintColor = .gray
        
        self.reloadInputViews()

        
        self.commentsTable.didLayout = { [weak self] in
            if let point = self?.inputAccessoryView?.convert(CGPoint(x:0, y:self!.inputAccessoryView!.bounds.height - 44), to: nil) {
     //       NSLog("Point: \(String(describing: point))")
            
                if self != nil {
                    let minY = self!.view.bounds.height - self!.p_keyboardHeight - /*self!.inputAccessoryView!.bounds.height*/44
                    let maxY = self!.view.bounds.height - /*self!.inputAccessoryView!.bounds.height*/44
                    let currentY = point.y
                    var progress = (currentY - minY) / (maxY - minY)
                    if (maxY == minY) {
                        progress = 1
                    }
                    if (progress > 1.0) {
                        progress = 1.0
                    } else if (progress < 0.0) {
                        progress = 0.0
                    }
                    progress = 1.0 - progress
                    
                    self?.p_btnSendWidthConstraint!.constant = self!.BTN_SEND_WIDTH * progress
                    self?.p_btnSendHeightConstraint!.constant = self!.BTN_SEND_HEIGHT * progress
                    self?.p_textFieldRightConstraint!.constant = (self!.BTN_SEND_WIDTH + 8) * progress + 8
                    self?.p_btnSend!.titleLabel!.font = self?.p_btnSend?.titleLabel?.font.withSize(self!.p_sendFontSize * progress)
                }
                    
            }
        }
     //   let item = UIBarButtonItem(image: UIImage(named:"Empty"), style: UIBarButtonItemStyle.plain, target: nil, action: nil)
    //    self.navigationItem.setRightBarButton(item, animated: true)
        
        self.updateTimer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(onUpdateTimer), userInfo: nil, repeats: true)
        
        if (self.friendsTableHeight != nil) {
            self.friendsTableHeight!.constant = 0
        }
        self.loadContacts()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.setEditing(false, animated: true)
        
        if (self.updateTimer != nil) {
            self.updateTimer!.invalidate()
            self.updateTimer = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if (self.p_textField != nil) {
            self.p_savedInputText = self.p_textField?.text
            self.p_textField?.removeObserver(self, forKeyPath: "selectedTextRange")
        }
        self.p_textField?.removeFromSuperview()
        self.p_textField = nil
        self.p_btnSend?.removeFromSuperview()
        self.p_btnSend = nil
        self.friendsTable?.removeFromSuperview()
        self.friendsTable = nil
        self.p_inputView?.removeFromSuperview()
        self.p_inputView = nil
    }
    
    func onUpdateTimer() {
        if (self.workout != nil && !self.p_isWorkoutsLoadingInProgress) {
            self.p_isWorkoutsLoadingInProgress = true
            self.workout?.updateComments(completed: { [weak self] (WorkoutInfo, hasUpdates:Bool) in
                DispatchQueue.main.async { [weak self] in
                    if let strongSelf = self {
                        strongSelf.p_comments = strongSelf.workout!.comments.filter({ (info:CommentInfo) -> Bool in
                            return info.is_active == true
                        })
                    }
                    self?.commentsTable.reloadData()
                    if (hasUpdates) {
                        if let strongSelf = self {
                            if (strongSelf.tableView(strongSelf.commentsTable, numberOfRowsInSection: 0) > 0) {
                                strongSelf.commentsTable.scrollToRow(at: IndexPath(row:(strongSelf.tableView(strongSelf.commentsTable, numberOfRowsInSection: 0)) - 1, section:0), at: .bottom, animated: false)
                            }
                        }
                    }
                    self?.p_isWorkoutsLoadingInProgress = false
                }
            }, fail: { [weak self] (message:String?) in
                NSLog("Fail update comments: \(message)")
                self?.p_isWorkoutsLoadingInProgress = false
            })
        }
    }
    
    
    func onKeyboardWillChangeFrame(_ notify: Notification?) {
        if (notify?.userInfo != nil) {
            let duration = notify!.userInfo![UIKeyboardAnimationDurationUserInfoKey]  as! TimeInterval
            let endFrame = self.view.convert(notify!.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect, from: nil)
            if (self.p_keyboardHeight == 0) {
                self.p_keyboardHeight = endFrame.height
            }
            let options = UIViewAnimationOptions(rawValue:
                (notify!.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uintValue << 16)
            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: {
                            self.commentsTable.contentInset.bottom = self.view.frame.maxY - endFrame.minY
                            self.commentsTable.scrollIndicatorInsets.bottom = self.view.frame.maxY - endFrame.minY
                            
                            self.view.layoutSubviews()
            }, completion: { (Bool) in
                
            })
        }
    }
    
    func onSend() {
        if (self.p_textField!.text != nil && !self.p_textField!.text!.isEmpty) {
            NSLog("Send pressed")
            var text = ""
            var usersNames = Set<String>()
            var emails = Set<String>()
            var phones = Set<String>()
            var unknownUsers = Set<String>()
            if (self.p_taggedUsers.count == 0) {
                text = self.p_textField!.text!
            } else {
                let sortedTags = self.p_taggedUsers.sorted(by: { (tag1, tag2) -> Bool in
                    return tag1.range!.location < tag2.range!.location
                })
                var lastPosition = 0
                for tag in sortedTags {
                    if lastPosition != tag.range!.location {
                        let from = self.p_textField!.text!.index(self.p_textField!.text!.startIndex, offsetBy: lastPosition)
                        let to = self.p_textField!.text!.index(self.p_textField!.text!.startIndex, offsetBy: tag.range!.location)
                        text += self.p_textField!.text!.substring(with: from..<to)
                    }
                    let trimmedUsername = tag.info!.username.replacingOccurrences(of: " ", with: "")
                    text += "@\(trimmedUsername)"
                    lastPosition = tag.range!.location + tag.range!.length
                    if (tag.info!.username.isEmail()) {
                        emails.insert(tag.info!.username)
                    } else if (tag.info!.username.isPhoneNumber()) {
                        phones.insert(tag.info!.username.getPhoneNumber())
                    } else {
                        if (tag.info!.id != 0) {
                            usersNames.insert(tag.info!.username)
                        } else {
                          //  let trimmedUsername = tag.info!.username.replacingOccurrences(of: " ", with: "")
                            unknownUsers.insert(tag.info!.username)
                        }
                    }
                }
                if (lastPosition < self.p_textField!.text!.count - 1) {
                    let from = self.p_textField!.text!.index(self.p_textField!.text!.startIndex, offsetBy: lastPosition)
                    text += self.p_textField!.text!.suffix(from: from)
                }
            }
            WorkoutsManager.shared.PostComment(comment: text, workout: self.workout!,
                                               taggedUsers: usersNames.flatMap{return $0},
                                               taggedEmails: emails.flatMap{return $0},
                                               taggedPhones: phones.flatMap{return $0},
                                               taggedDisplayNames: unknownUsers.flatMap{return $0},
                                               onSuccess: { [weak self] (WorkoutInfo) in
                if let strongSelf = self {
                    strongSelf.p_comments = strongSelf.workout!.comments.filter({ (info:CommentInfo) -> Bool in
                        return info.is_active == true
                    })
                    strongSelf.commentsTable.reloadData()
                    if (strongSelf.tableView(strongSelf.commentsTable, numberOfRowsInSection: 0) > 0) {
                        strongSelf.commentsTable.scrollToRow(at: IndexPath(row:strongSelf.tableView(strongSelf.commentsTable, numberOfRowsInSection: 0) - 1, section:0), at: .bottom, animated: false)
                    }
                }
            }, onFail: { [weak self] (message: String?) in
                let alert = UIAlertController(title: "Attention",
                                              message: message,
                                              preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: UIAlertActionStyle.cancel,
                                              handler: { (action: UIAlertAction) in
                }))
                self?.present(alert, animated: true, completion: nil)
            })
            self.p_textField!.text = nil
            self.p_textField!.attributedText = nil
            self.p_taggedUserNames = Set<String>()
            self.p_taggedUsers = [TagInfo]()
            self.p_textField!.resignFirstResponder()
        }
    }
}

extension CommentsVC: UITableViewDataSource {
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.commentsTable == tableView) {
            if (self.p_comments != nil) {
                if (self.p_comments!.count == 0) {
                    self.showEmpty()
                } else {
                    self.hideEmpty()
                }
                return self.p_comments!.count
            }
            if (self.workout != nil) {
                self.p_comments = self.workout!.comments.filter({ (info:CommentInfo) -> Bool in
                    return info.is_active == true
                })
                //return self.workout!.comments.count
                if (self.p_comments != nil) {
                    if (self.p_comments!.count == 0) {
                        self.showEmpty()
                    } else {
                        self.hideEmpty()
                    }
                    return self.p_comments!.count
                }
            }
            self.showEmpty()
        } else if (self.friendsTable == tableView) {
            if (self.friends != nil) {
                return self.friends!.count
            }
        }
        return 0
    }
    
    fileprivate func showEmpty() {
        UIView.animate(withDuration: 0.2) {
            self.emptyView.alpha = 1.0
        }
    }
    fileprivate func hideEmpty() {
        UIView.animate(withDuration: 0.2) {
            self.emptyView.alpha = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.commentsTable) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentsCell
            
    //        let opponentStr = self.opponents[indexPath.row]
    //        let messageStr = self.comments[indexPath.row]
    //        let timeStr = self.time[indexPath.row]
            let info  = self.p_comments![indexPath.row]// self.workout!.comments[indexPath.row]
            if (info.username == ServerManager.shared.currentUser!.username) {
                cell.btnDelete.isHidden = false
                cell.comment = info
                cell.onDeleteHandler = { [weak self] (commentInfo:CommentInfo?) in
                    if let strongSelf = self {
                        let alert = UIAlertController(title: "Attention",
                                                      message: "Delete comment?",
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK",
                                                      style: UIAlertActionStyle.default,
                                                      handler: { (action: UIAlertAction) in
                                                        WorkoutsManager.shared.DeleteComment(comment: commentInfo!, workout: strongSelf.workout!, onSuccess: { (_) in
                                                            strongSelf.p_comments = strongSelf.workout!.comments.filter({ (info:CommentInfo) -> Bool in
                                                                return info.is_active == true
                                                            })
                                                            strongSelf.commentsTable.reloadData()
                                                        }, onFail: nil)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel",
                                                      style: UIAlertActionStyle.cancel,
                                                      handler: { (action: UIAlertAction) in
                                                        
                        }))
                        strongSelf.present(alert, animated: true, completion:{})
                    }
                }
            } else {
                cell.btnDelete.isHidden = true
                cell.onDeleteHandler = nil
            }
            
            var opponentStr = info.username
            if (self.p_users[info.username] != nil) {
                opponentStr = self.userFullName(self.p_users[info.username]!)
            } else {
                UsersManager.shared.getUser(userName: info.username, completed: { [weak self] (userInfo: UserInfo) in
                    self?.p_users[userInfo.username] = userInfo
                    DispatchQueue.main.async {
                        self?.commentsTable.beginUpdates()
                        cell.nameLabel.text = self?.userFullName(userInfo)
                        self?.commentsTable.endUpdates()
                    }
                })
            }
            var messageStr = info.text
            
            var timeStr = ""
            if (info.init_time != nil) {
                timeStr = Date().agoFromDate(date: info.init_time!)
            }
            
            if (self.USE_NEW_USER_INVITED) {
                var emails = [NSRange]()
                var emailTags = [NSRange]()
                
                // Replace emailTags with *NewUserInvIteD!
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                detector.enumerateMatches(in: messageStr, options: [], range: NSRange(messageStr.startIndex..<messageStr.endIndex, in: messageStr), using: { (url:NSTextCheckingResult?, _, _) in
                    if (url != nil && url!.resultType == .link && url!.url != nil) {
                        if (url!.url!.scheme == "mailto") {
                            var isEmailTag = false
                            if (url!.range.location > 0) {
                                let from = messageStr.index(messageStr.startIndex, offsetBy: url!.range.location - 1)
                                let symbol = messageStr[from]
                                if (symbol == "@") {
                                    isEmailTag = true
                                }
                            }
                            if (isEmailTag) {
                                emailTags.append(url!.range)
                            #if DEBUG
                                let from = messageStr.index(messageStr.startIndex, offsetBy: url!.range.location)
                                let to = messageStr.index(from, offsetBy: url!.range.length)
                                NSLog("Email Tag: \(messageStr.substring(with: from..<to))")
                            #endif
                            }
                        }
                    }
                })
                let sortedEmailTags = emailTags.sorted(by: { (range1, range2) -> Bool in
                    return range1.location > range2.location
                })
                for item in sortedEmailTags {
                    let from = messageStr.index(messageStr.startIndex, offsetBy: item.location)
                    let to = messageStr.index(from, offsetBy: item.length)
                    messageStr = messageStr.replacingCharacters(in: from..<to, with: "*NewUserInvIteD!")
                }
                // Search emails in edited string
                detector.enumerateMatches(in: messageStr, options: [], range: NSRange(messageStr.startIndex..<messageStr.endIndex, in: messageStr), using: { (url:NSTextCheckingResult?, _, _) in
                    if (url != nil && url!.resultType == .link && url!.url != nil) {
                        if (url!.url!.scheme == "mailto") {
                            var isEmailTag = false
                            if (url!.range.location > 0) {
                                let from = messageStr.index(messageStr.startIndex, offsetBy: url!.range.location - 1)
                                let symbol = messageStr[from]
                                if (symbol == "@") {
                                    isEmailTag = true
                                }
                            }
                            if (!isEmailTag) {
                                emails.append(url!.range)
                                #if DEBUG
                                    let from = messageStr.index(messageStr.startIndex, offsetBy: url!.range.location)
                                    let to = messageStr.index(from, offsetBy: url!.range.length)
                                    NSLog("Email: \(messageStr.substring(with: from..<to))")
                                #endif
                            }
                        }
                    }
                })
                
                var components = messageStr.components(separatedBy: CharacterSet(charactersIn:"@"))
                var offset = 0
                if (components.count > 1) {
                    for (index, item) in components.enumerated() {
                        var isOffsetInEmailRange = false
                        for emailRange in emails {
                            if (emailRange.contains(offset)) {
                                isOffsetInEmailRange = true
                                break
                            }
                        }
                        if (index > 0 && !isOffsetInEmailRange) {
                            let range = item.rangeOfCharacter(from: CharacterSet(charactersIn:" .,:;!?\"'={}()[]<>/\\"), options: String.CompareOptions.caseInsensitive, range: nil)
                            if (range != nil) {
                                let testUserName = item.prefix(upTo: range!.lowerBound)
                                if (testUserName != "*NewUserInvIteD") {
                                    if (!info.mentioned_names.contains(String(testUserName))) {
                                        components[index] = "*New user invited" + item.suffix(from: range!.lowerBound)
                                    }
                                }
                            } else {
                                if (item != "*NewUserInvIteD") {
                                    if (!info.mentioned_names.contains(item)) {
                                        components[index] = "*New user invited"
                                    }
                                }
                            }
                        }
                        offset += item.count + 1
                    }
                    messageStr = components.joined(separator: "@")
                }
                messageStr = messageStr.replacingOccurrences(of: "*NewUserInvIteD!", with: "*New user invited")
            }
            
            cell.nameLabel.text = opponentStr
            //cell.messageView.text = messageStr
            let attrStr = NSMutableAttributedString(string: messageStr, attributes:[NSFontAttributeName: cell.messageView.font!])
            for taggedFriend in info.mentioned_names {
                var startIndex = messageStr.startIndex
                let endIndex = messageStr.endIndex
                var textRange = startIndex..<endIndex
                var range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                while (range != nil) {
                    let loc = messageStr.distance(from: messageStr.startIndex, to: range!.lowerBound)
                    var len = messageStr.distance(from: range!.lowerBound, to: range!.upperBound)
                    if let user = self.p_users[taggedFriend] {
                        let userFullName = self.userFullName(user)
                        let nsRange = NSMakeRange(loc, len)
                        len = userFullName.count + 1
                        messageStr.replaceSubrange(range!, with: "@\(userFullName)")
                    //    attrStr.deleteCharacters(in: nsRange)
                    //    attrStr.insert(NSAttributedString(string: "@\(userFullName)"), at: nsRange.location)
                        attrStr.replaceCharacters(in: nsRange, with: "@\(userFullName)")
                    } else {
                        UsersManager.shared.getUser(userName: taggedFriend, completed: { [weak self] (userInfo: UserInfo) in
                                self?.p_users[userInfo.username] = userInfo
                                DispatchQueue.main.async {
                                    self?.commentsTable.reloadRows(at: [indexPath], with: .none)
                                }
                            }, fail: { [weak self] in
                                if let strongSelf = self {
                                    if (strongSelf.USE_NEW_USER_INVITED) {
                                        let userInfo = UserInfo(info: ["username": taggedFriend])
                                        strongSelf.p_users[userInfo.username] = userInfo
                                        DispatchQueue.main.async {
                                            strongSelf.commentsTable.reloadRows(at: [indexPath], with: .none)
                                        }
                                    }
                                }
                        })
                    }
                    let nsRange = NSMakeRange(loc, len)
                    attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:nsRange)
                    startIndex = range!.upperBound
                    textRange = startIndex..<endIndex
                    
                    range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                }
            }
            for taggedFriend in info.mentioned_emails {
                var startIndex = messageStr.startIndex
                let endIndex = messageStr.endIndex
                var textRange = startIndex..<endIndex
                var range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                while (range != nil) {
                    let loc = messageStr.distance(from: messageStr.startIndex, to: range!.lowerBound)
                    let len = messageStr.distance(from: range!.lowerBound, to: range!.upperBound)
                    let nsRange = NSMakeRange(loc, len)
                    attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:nsRange)
                    
                    startIndex = range!.upperBound
                    textRange = startIndex..<endIndex
                    range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                }
            }
            for taggedFriend in info.mentioned_phones {
                var startIndex = messageStr.startIndex
                let endIndex = messageStr.endIndex
                var textRange = startIndex..<endIndex
                var range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                while (range != nil) {
                    let loc = messageStr.distance(from: messageStr.startIndex, to: range!.lowerBound)
                    let len = messageStr.distance(from: range!.lowerBound, to: range!.upperBound)
                    let nsRange = NSMakeRange(loc, len)
                    attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:nsRange)
                    
                    startIndex = range!.upperBound
                    textRange = startIndex..<endIndex
                    range = messageStr.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                }
            }
            if (self.USE_NEW_USER_INVITED) {
                let testString = attrStr.string
                var range = testString.range(of: "@*New user invited")
                while (range != nil) {
                    let loc = messageStr.distance(from: testString.startIndex, to: range!.lowerBound)
                    let len = messageStr.distance(from: range!.lowerBound, to: range!.upperBound)
                    let nsRange = NSMakeRange(loc, len)
                    let color = UIColor(r: 0xBB, g: 0xBB, b: 0xBB)
                    let backColor = UIColor(r:245, g:245, b:245)
                    attrStr.addAttributes([NSForegroundColorAttributeName : color,
                                           NSBackgroundColorAttributeName : backColor], range: nsRange)
                    
                    range = testString.range(of: "@*New user invited", options: String.CompareOptions(), range: range!.upperBound..<testString.endIndex, locale: nil)
                }
            }
            cell.messageView.attributedText = attrStr
            cell.timeLabel.text = timeStr
            
            if (!info.avatarURL.isEmpty) {
                var imageURL = URL(string: info.avatarURL)
                if (imageURL == nil) {
                    imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
                }
                cell.avatarView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
            } else {
                if let userInfo = FriendsManager.shared.FriendWith(nick: info.username) {
                    info.avatarURL = userInfo.profile_picture_url

                    var imageURL = URL(string: info.avatarURL)
                    if (imageURL == nil) {
                        imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
                    }
                    cell.avatarView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
                } else {
                    UsersManager.shared.getUser(userName: info.username, completed: { (userInfo:UserInfo) in
                        info.avatarURL = userInfo.profile_picture_url
                        var imageURL = URL(string: info.avatarURL)
                        if (imageURL == nil) {
                            imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
                        }
                        cell.avatarView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
                    }, fail: {
                        let imageURL = Bundle.main.url(forResource: "groupieAvatar.png", withExtension: nil)
                        cell.avatarView.sd_setImage(with: imageURL, placeholderImage: UIImage(named:"UserPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
                    })
                }
            }
            
            return cell
        } else if (tableView == self.friendsTable!) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! POST_View_Cell
            let friend = self.friends![indexPath.row]

            cell.titleLabel.text = self.userFullName(friend)
            return cell
        }
        return UITableViewCell()
    }

    
}

extension CommentsVC: UITableViewDelegate {
    
 /*   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (tableView == self.commentsTable) {
            if (self.p_textView == nil) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentsCell
                self.p_textView = UITextView(frame: cell.messageView.frame)
                self.p_textView!.font = cell.messageView.font!
                
                self.p_textBottomSpace = cell.messageBottomConstraint.constant
            }
            
            //let message = self.comments[indexPath.row]
            let info  = self.workout!.comments[indexPath.row]
            let message = info.text
            
            
            //self.p_textView!.text = message
            //let textSize = self.p_textView?.sizeThatFits(CGSize(width: self.p_textView!.frame.width, height: CGFloat(INT_MAX)))
            let textSize = message.sizeWithFont(self.p_textView!.font!, forWidth: self.view.bounds.width - 170)
            
            
            return self.p_textView!.frame.minY + textSize.height + self.p_textBottomSpace + 16
        } else if (tableView == self.friendsTable!) {
            return 25
        }
        return 0
    }*/
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
        if (self.USE_NEW_USER_INVITED) {
            if (user.first_name.isEmpty && user.last_name.isEmpty && user.display_name.isEmpty) {
                userFullName = "*New user invited"
            }
        }
        return userFullName
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.friendsTable) {
            if var testString = self.p_textField!.text {
                let curPosition = self.p_textField!.selectedTextRange!.end
                let offset = self.p_textField!.offset(from: self.p_textField!.beginningOfDocument, to: curPosition)
                let posIndex = testString.index(testString.startIndex, offsetBy: offset)
                let endOfString = testString.substring(from: posIndex)
                testString = testString.substring(to: posIndex)
                var components = testString.components(separatedBy: CharacterSet(charactersIn:"@"))
                if (components.count > 1) {
                    let lastComponentLength = components.last!.count
                    components.removeLast()
                    
                    let friend = self.friends![indexPath.row]
                    self.p_taggedUserNames.insert(friend.username)
                    
                    let prefixText = components.joined(separator: "@")
                    let fullUserName = self.userFullName(friend)
                    let loc = prefixText.count
                    let len = fullUserName.count + 1
                    let delta = len - lastComponentLength
                    for (index, tag) in p_taggedUsers.enumerated() {
                        if (tag.range!.location >= loc) {
                            var tmpTag = tag
                            tmpTag.range!.location += delta
                            self.p_taggedUsers[index] = tmpTag
                        }
                    }
                    self.p_taggedUsers.append(TagInfo(info: friend, range: NSMakeRange(loc, len)))
                    components.append(fullUserName)
                    
                    let newText = components.joined(separator: "@") + " " + endOfString
                    self.p_textField!.text = newText
                    
                    let attrStr = NSMutableAttributedString(string: newText)
                    
                    for taggedFriend in self.p_taggedUsers {
                        attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:taggedFriend.range!)
                    }
                    self.p_textField!.attributedText = attrStr
                }

            }
            self.friends = nil
            self.friendsTableHeight?.constant = 0
            self.p_bottomBar.customHeight = 44
            self.friendsTable?.reloadData()
        }
    }
}

extension CommentsVC : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if (string == "\n") {
            return true
        } else {
            if (textField == self.p_textField!) {
                var from = textField.text?.index(textField.text!.startIndex, offsetBy: range.location)
                var to = textField.text?.index(from!, offsetBy: range.length)
                var cursorPosition: Int? = nil
                var newText = textField.text
                if (newText != nil) {
                    var taggedFriendsForRemove = [TagInfo]()
                    for taggedFriend in self.p_taggedUsers {
                        if (range.intersection(taggedFriend.range!) != nil) {
                            taggedFriendsForRemove.append(taggedFriend)
                            cursorPosition = range.location + string.count
                            if (taggedFriend.range!.location < range.location) {
                                cursorPosition = taggedFriend.range!.location + string.count
                                from = textField.text?.index(textField.text!.startIndex, offsetBy: taggedFriend.range!.location)
                            }
                            if (taggedFriend.range!.upperBound > range.upperBound) {
                                to = textField.text?.index(textField.text!.startIndex, offsetBy: taggedFriend.range!.upperBound)
                            }
                        }
                    }
                    for tagForRemove in taggedFriendsForRemove {
                        if let index = self.p_taggedUsers.index(where: { (savedTag: TagInfo) -> Bool in
                            return savedTag.range! == tagForRemove.range!
                        }) {
                            self.p_taggedUsers.remove(at: index)
                        }
                    }
                }

                if (textField.text != nil) {
                    let delta = textField.text!.distance(from: from!, to: to!) - string.count
                    let startPosition = textField.text!.distance(from: textField.text!.startIndex, to: from!)
                    for (index, tag) in p_taggedUsers.enumerated() {
                        if (tag.range!.location >= startPosition) {
                            var tmpTag = tag
                            tmpTag.range!.location -= delta
                            self.p_taggedUsers[index] = tmpTag
                        }
                    }
                }
                newText = textField.text?.replacingCharacters(in: from!..<to!, with: string)
               
                if (newText != nil) {
                    let attrStr = NSMutableAttributedString(string: newText!)
                    for taggedFriend in self.p_taggedUsers {
                        attrStr.addAttributes([NSBackgroundColorAttributeName: UIColor(r:225, g:225, b:225)], range:taggedFriend.range!)
                    }
                    if (cursorPosition == nil) {
                        cursorPosition = range.location + string.count
                    }
                    
                    self.p_textField!.text = newText
                    self.p_textField!.attributedText = attrStr
                    let tttBegin = self.p_textField!.beginningOfDocument
                    let tttStart = self.p_textField!.position(from: tttBegin, offset: cursorPosition!)
                    let tttEnd = self.p_textField!.position(from: tttBegin, offset: cursorPosition!)
                    if (tttStart != nil && tttEnd != nil) {
                        let tttRange = self.p_textField!.textRange(from: tttStart!, to: tttEnd!)
                        self.p_textField!.selectedTextRange = tttRange
                    }
                    return false
                }
            }
        }
        return true
    }
    
    
    fileprivate func searchFriends(newText: String?) {
        if (newText != nil && newText!.count > 0) {
            DispatchQueue.global().async {
                var tmpFriends = FriendsManager.shared.followers
                tmpFriends.append(contentsOf: FriendsManager.shared.following)
                
                var result = [UserInfo]()
                for user in tmpFriends {
                    let userFullName = self.userFullName(user)
                    if (userFullName.range(of: newText!, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
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
                
            /*    if (result.count < self.MAX_FRIENDS_COUNT) {
                    if (newText!.isPhoneNumber()) {
                        var phoneText = newText!
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
                            if (email.range(of: newText!, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
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
                                if (name.range(of: newText!, options: [String.CompareOptions.caseInsensitive], range: nil, locale: nil) != nil) {
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
                }
                
                */
                
                DispatchQueue.main.async {
                    self.friends = result
                    if (self.friends != nil && self.friendsTableHeight != nil) {
                        self.p_bottomBar.customHeight = CGFloat(self.friendsTable!.estimatedRowHeight * CGFloat(self.tableView(self.friendsTable!, numberOfRowsInSection: 0))) + 44
                        self.friendsTableHeight!.constant = CGFloat(self.friendsTable!.estimatedRowHeight * CGFloat(self.tableView(self.friendsTable!, numberOfRowsInSection: 0)))
                    } else {
                        self.friendsTableHeight?.constant = 0
                        self.p_bottomBar.customHeight = 44
                    }
                    self.friendsTable?.reloadData()
                }
            }
        } else {
            self.friends = nil
            self.friendsTableHeight?.constant = 0
            self.p_bottomBar.customHeight = 44
            self.friendsTable?.reloadData()
        }
    }
}

extension CommentsVC {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "selectedTextRange") {
    //        NSLog("Touched")
            if (self.p_textField!.text != nil) {
                if var testString = self.p_textField!.text {
                    let curPosition = self.p_textField!.selectedTextRange!.end
                    let offset = self.p_textField!.offset(from: self.p_textField!.beginningOfDocument, to: curPosition)
                    
                    var range = NSMakeRange(offset, 0)
                    if (offset > 0) {
                        range = NSMakeRange(offset - 1, 1)
                    }
                    for taggedFriend in self.p_taggedUserNames {
                        var startIndex = testString.startIndex
                        let endIndex = testString.endIndex
                        var textRange = startIndex..<endIndex
                        var tagRange = testString.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                        while (tagRange != nil) {
                            let loc = testString.distance(from: testString.startIndex, to: tagRange!.lowerBound)
                            let len = testString.distance(from: tagRange!.lowerBound, to: tagRange!.upperBound)
                            let nsRange = NSMakeRange(loc, len)
                            if (range.intersection(nsRange) != nil) {
                                self.searchFriends(newText: nil)
                                return
                            }
                            
                            startIndex = tagRange!.upperBound
                            textRange = startIndex..<endIndex
                            tagRange = testString.range(of: "@\(taggedFriend)", options: String.CompareOptions(), range: textRange, locale: nil)
                        }
                    }
                    
                    testString = testString.substring(to: testString.index(testString.startIndex, offsetBy: offset))
                    let components = testString.components(separatedBy: CharacterSet(charactersIn:"@"))
                    if (components.count > 1) {
                        self.searchFriends(newText: components.last!)
                    } else {
                        self.searchFriends(newText: nil)
                    }
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
}
