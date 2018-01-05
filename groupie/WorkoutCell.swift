//
//  WorkoutCell.swift
//  groupie
//
//  Created by Sania on 6/16/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class WorkoutCell: UITableViewCell {
    
    enum WorkoutButtonType : Int {
        case join
        case leave
        case edit
    }
    
    var workoutInfo: WorkoutInfo?
    
    @IBOutlet weak var btnAvatar: UIButton?
    @IBOutlet weak var opponentsLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var btnMessage: UIButton?
    @IBOutlet weak var btnLike: UIButton?
    @IBOutlet weak var btnJoin: RoundedButton?
    @IBOutlet weak var btnComments: UIButton?
    @IBOutlet weak var cAvatarLeft: NSLayoutConstraint?
    @IBOutlet weak var cAvatarWidth: NSLayoutConstraint?
    @IBOutlet weak var cAvatarToOpponentsSpace: NSLayoutConstraint?
    @IBOutlet weak var cOpponentsRight: NSLayoutConstraint?
    @IBOutlet weak var cLikeWidth: NSLayoutConstraint?
    @IBOutlet weak var cMessageWidth: NSLayoutConstraint?
    @IBOutlet weak var cJoinRight: NSLayoutConstraint?
    @IBOutlet weak var cJoinHeight: NSLayoutConstraint?
    @IBOutlet weak var bottomOffset: NSLayoutConstraint?
    @IBOutlet weak var btnWhere: UIButton?
    @IBOutlet weak var btnBody: UIButton?
    @IBOutlet weak var whereMaxHeightConstraint : NSLayoutConstraint?
    @IBOutlet weak var bodyMaxHaightConstraint : NSLayoutConstraint?
    
    fileprivate var defCAvatarLeft: CGFloat = 0
    fileprivate var defCOpponentsLabelRight: CGFloat = 0
    fileprivate var defCLikeWidth: CGFloat = 0
    fileprivate var defCMessageWidth: CGFloat = 0
    fileprivate var defCJoinRight: CGFloat = 0
    fileprivate var defCJoinHeight: CGFloat = 0
    fileprivate var defFOpponents: CGFloat = 0
    fileprivate var defFMessage: CGFloat = 0
    fileprivate var defFDate: CGFloat = 0
    fileprivate var defFJoin: CGFloat = 0
    fileprivate var defBJoinFontSize: CGFloat = 0
    fileprivate var isDefInitialized = false
    fileprivate var p_commentsCount: Int = 0
    fileprivate var defWhereOriginalHeight: CGFloat?
    fileprivate var defBodyOriginalHeight: CGFloat?
    fileprivate var p_buttonType: WorkoutButtonType = .join
    fileprivate var p_isDefJoinInitialized: Bool = false
    
    var opponentsLiteColor: UIColor = UIColor(white: 155/255, alpha: 1.0)
    var opponentsDarkColor: UIColor = UIColor(white: 55/255, alpha: 1.0)
    var opponentsDarkSelectedColor: UIColor = UIColor(white: 55/255, alpha: 0.5)
    
    var onComments:((WorkoutInfo?)->Void)?
    var onJoin:((WorkoutInfo?)->Void)?
    var onLeave:((WorkoutInfo?)->Void)?
    var onEdit:((WorkoutInfo?)->Void)?
    var onLike:((WorkoutInfo?)->Void)?
    var onAvatar:((WorkoutInfo?)->Void)?
    var onUserTapped:((String?)->Void)?
    var onAddressTapped:((String?)->Void)?
    var onURLTapped:((URL?)->Void)?
    var onWhere:((WorkoutCell, WorkoutInfo?)->Void)?
    var onBody:((WorkoutCell, WorkoutInfo?)->Void)?
    var onNeedResize:((WorkoutCell)->Void)?
    
    fileprivate var p_touch: UITouch?
    fileprivate var p_opponentsRanges = [NSRange]()
    fileprivate var p_writerRange = NSRange()
    fileprivate var p_addressRange = NSRange()
    fileprivate var p_urlRanges = [NSRange]()
    fileprivate var p_urls = [URL]()
    fileprivate var p_needCalcRects = false
    fileprivate var p_needAutoresize = false
    fileprivate var p_touchedUserIndex: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (self.btnBody != nil) {
            self.btnBody!.isUserInteractionEnabled = false
        }
        
        if (self.opponentsLabel != nil) {
            self.defFOpponents = self.opponentsLabel!.font.pointSize
        }
        if (self.messageLabel != nil) {
            self.defFMessage = self.messageLabel!.font.pointSize
        }
        if (self.dateLabel != nil) {
            self.defFDate = self.dateLabel!.font.pointSize
        }
        if (self.btnJoin != nil) {
            self.defFJoin = self.btnJoin!.titleLabel!.font.pointSize
        }
        
        if (self.cAvatarLeft != nil) {
            self.defCAvatarLeft = self.cAvatarLeft!.constant
        }
        if (self.cOpponentsRight != nil) {
            self.defCOpponentsLabelRight = self.cOpponentsRight!.constant
        }
        if (self.cLikeWidth != nil) {
            self.defCLikeWidth = self.cLikeWidth!.constant
        }
        if (self.cMessageWidth != nil) {
            self.defCMessageWidth = self.cMessageWidth!.constant
        }
        if (self.cJoinRight != nil) {
            self.defCJoinRight = self.cJoinRight!.constant
        }
        if (self.cJoinHeight != nil) {
            self.defCJoinHeight = self.cJoinHeight!.constant
        }
        
        if (self.whereMaxHeightConstraint != nil && self.defWhereOriginalHeight == nil) {
            self.defWhereOriginalHeight = self.whereMaxHeightConstraint!.constant
        }
        if (self.bodyMaxHaightConstraint != nil && self.defBodyOriginalHeight == nil) {
            self.defBodyOriginalHeight = self.bodyMaxHaightConstraint!.constant
        }
        
        let ratio = UIScreen.main.bounds.width / 414.0
        if (self.opponentsLabel != nil) {
            self.opponentsLabel!.font = self.opponentsLabel!.font.withSize(self.defFOpponents * ratio)
        }
        if (self.messageLabel != nil) {
            self.messageLabel!.font = self.messageLabel!.font.withSize(self.defFMessage * ratio)
        }
        if (self.dateLabel != nil) {
            self.dateLabel!.font = self.dateLabel!.font.withSize(self.defFDate * ratio)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }
    
    func setButtonType(_ buttonType: WorkoutButtonType) {
        self.p_buttonType = buttonType
        if (!self.p_isDefJoinInitialized) {
            self.p_isDefJoinInitialized = true
            self.defBJoinFontSize = self.btnJoin!.titleLabel!.font.pointSize
        }
        switch (self.p_buttonType) {
        case .leave:
            let normalImage = UIImage.fontAwesomeIcon(name: .minusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
            self.btnJoin!.setImage(normalImage, for: .normal)
            self.btnJoin!.setTitle("Leave", for: .normal)
            self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize - 3)
            break
        case .join:
            let normalImage = UIImage.fontAwesomeIcon(name: .plusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
            self.btnJoin!.setImage(normalImage, for: .normal)
            self.btnJoin!.setTitle("Join", for: .normal)
            self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize)
            break
        case .edit:
            let normalImage = UIImage.fontAwesomeIcon(name: .pencil, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
            self.btnJoin!.setImage(normalImage, for: .normal)
            self.btnJoin!.setTitle("Edit", for: .normal)
            self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize)
            break
        }
    }
    
    fileprivate var p_users = [String: UserInfo]()
    
    fileprivate var p_writer: String?
    var writer: String? { get {
            return self.p_writer
        }
        set {
            self.p_writer = newValue
            UsersManager.shared.getUser(userName: self.p_writer, completed: { (user:UserInfo) in
                self.p_users[user.username] = user
                self.setOpponentsString()
                self.onNeedResize?(self)
            })
            self.setOpponentsString()
        }
    }
    fileprivate var p_location: String?
    var location: String? { get {
            return self.p_location
        }
        set {
            self.p_location = newValue
            self.setOpponentsString()
        }
    }
    fileprivate var p_opponents: [String]?
    var opponents: [String]? { get {
            return self.p_opponents
        }
        set {
            self.p_opponents = newValue
            if (self.p_opponents != nil) {
                for userName in self.p_opponents! {
                    UsersManager.shared.getUser(userName: userName, completed: { (user:UserInfo) in
                        self.p_users[user.username] = user
                        self.setOpponentsString()
                        self.onNeedResize?(self)
                    })
                }
            }
            self.setOpponentsString()
        }
        
    }
    
    fileprivate func setOpponentsString() {
        self.p_writerRange = NSRange()
        self.p_addressRange = NSRange()
        self.p_opponentsRanges = [NSRange]()
        self.p_needCalcRects = true
        
        if (self.opponentsLabel != nil) {
            if (self.p_opponents != nil) {
                let attributedText = NSMutableAttributedString()
                if (self.writer != nil && !self.writer!.isEmpty) {
                    let startIndex = attributedText.length
                    var writerName = self.writer!
                    if let writerInfo = self.p_users[self.p_writer!] {
                        var writer = writerInfo.first_name.trimmingCharacters(in: CharacterSet.whitespaces)
                        if (!writer.isEmpty && !writerInfo.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                            writer += " "
                        }
                        writer += writerInfo.last_name.trimmingCharacters(in: CharacterSet.whitespaces)
                        if (!writer.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                            writerName = writer
                        } else if (!writerInfo.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                            writerName = writerInfo.display_name
                        }
                    }
                    attributedText.append(NSAttributedString(string: writerName, attributes: [NSForegroundColorAttributeName: (-100 == self.p_touchedUserIndex ? self.opponentsDarkSelectedColor : self.opponentsDarkColor), NSFontAttributeName : self.opponentsLabel!.font]))
                    let endIndex = attributedText.length
                    self.p_writerRange = NSRange(location:startIndex, length: endIndex - startIndex)
                }
                if (self.location != nil && !self.location!.isEmpty) {
                    if (attributedText.length == 0) {
                        attributedText.append(NSAttributedString(string: "At ", attributes: [NSForegroundColorAttributeName: self.opponentsLiteColor, NSFontAttributeName : self.opponentsLabel!.font]))
                    } else {
                        attributedText.append(NSAttributedString(string: " at ", attributes: [NSForegroundColorAttributeName: self.opponentsLiteColor, NSFontAttributeName : self.opponentsLabel!.font]))
                    }
                    let startIndex = attributedText.length
                    var locText = self.location!
                    if let addressLocation = locText.range(of: " - ") {
                        let offset = locText.index(after: addressLocation.upperBound)
                        let addrSubStr = locText.substring(from: offset)
                        if addrSubStr.characters.count > 25 {
                            let endPos = locText.index(addressLocation.upperBound, offsetBy: 20)
                            let endLocText = locText.substring(from: endPos)
                            locText = locText.substring(to:endPos)
                            let characters = ".,"
                            for (_, locChar) in endLocText.characters.enumerated() {
                                if (characters.contains(locChar)) {
                                    break
                                }
                                locText += String(locChar)
                            }
                      /*      locText = locText.trimmingCharacters(in: CharacterSet(charactersIn: " .,"))
                            locText += "..."*/
                        }
                    }
                    var font = self.opponentsLabel!.font
                    if (self.workoutInfo!.is_google_place) {
                        font = UIFont.boldSystemFont(ofSize: self.opponentsLabel!.font.pointSize)
                    }
                    attributedText.append(NSAttributedString(string: locText, attributes: [NSForegroundColorAttributeName: (-200 == self.p_touchedUserIndex ? self.opponentsDarkSelectedColor : self.opponentsDarkColor), NSFontAttributeName : font!]))
                    let endIndex = attributedText.length
                    self.p_addressRange = NSRange(location:startIndex, length: endIndex - startIndex)
                    //attributedText.addAttributes([NSFontAttributeName:font], range: self.p_addressRange)
                }
                for (index, element) in self.p_opponents!.enumerated() {
                    if (true) {
                        if (index == 0) {
                            attributedText.append(NSAttributedString(string: " with ", attributes: [NSForegroundColorAttributeName: self.opponentsLiteColor, NSFontAttributeName : self.opponentsLabel!.font]))
                        } else {
                            attributedText.append(NSAttributedString(string: " and ", attributes: [NSForegroundColorAttributeName: self.opponentsLiteColor, NSFontAttributeName : self.opponentsLabel!.font]))
                        }
                        let startIndex = attributedText.length
                        var elementName = element
                        if let elementInfo = self.p_users[elementName] {
                            var user = elementInfo.first_name.trimmingCharacters(in: CharacterSet.whitespaces)
                            if (!user.isEmpty && !elementInfo.last_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                user += " "
                            }
                            user += elementInfo.last_name.trimmingCharacters(in: CharacterSet.whitespaces)
                            if (!user.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                elementName = user
                            } else if (!elementInfo.display_name.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty) {
                                elementName = elementInfo.display_name
                            }
                        }
                        attributedText.append(NSAttributedString(string: elementName, attributes: [NSForegroundColorAttributeName: (index == self.p_touchedUserIndex ? self.opponentsDarkSelectedColor : self.opponentsDarkColor), NSFontAttributeName : self.opponentsLabel!.font]))
                        let endIndex = attributedText.length
                        self.p_opponentsRanges.append(NSRange(location:startIndex, length: endIndex - startIndex))
                    }
                }
                self.opponentsLabel?.attributedText = attributedText
                self.opponentsLabel?.sizeToFit()
                if (!self.autosizeOpponents) {
                    if (self.opponentsLabel != nil && self.opponentsLabel!.attributedText != nil) {
                        let ratio = UIScreen.main.bounds.width / 414.0
                        let width = UIScreen.main.bounds.width - self.defCAvatarLeft * ratio - (self.cAvatarWidth?.constant ?? 0) - /*(self.cAvatarToOpponentsSpace?.constant ?? 0) -*/ self.defCOpponentsLabelRight * ratio//???
                        let opponentsHeight = self.opponentsLabel!.attributedText!.sizeForWidth(forWidth: width).height + 1
                        self.whereMaxHeightConstraint?.constant = opponentsHeight
                    }
                }
            } else {
                self.opponentsLabel?.text = nil
            }
        }
    }
    
    var commentsCount: Int { get {
            return self.p_commentsCount
        }
        set {
            self.p_commentsCount = newValue
            if (self.btnComments != nil) {
                var title = ""
                if (self.p_commentsCount == 1) {
                    title = "View Comment"
                } else if (self.p_commentsCount > 99) {
                    title = "View 99+ Comments"
                } else if (self.p_commentsCount > 1){
                    title = "View \(self.p_commentsCount) Comments"
                }
                self.btnComments?.setTitle(title, for: .normal)
            }
            if (self.p_commentsCount == 0) {
                self.bottomOffset?.constant = 24
            } else {
                self.bottomOffset?.constant = 60
            }
        }
    }
    
    fileprivate var p_likesCount: UInt = 0
    var likes: UInt { get { return self.p_likesCount}
        set {
            self.p_likesCount = newValue
            if (self.btnLike != nil) {
                if (self.p_likesCount == 0) {
                    self.btnLike!.setTitle("", for: .normal)
                } else {
                    var likesTitle = String(format:"%d", self.p_likesCount)
                    if (self.p_likesCount >= 100) {
                        likesTitle = "99+"
                    }
                    self.btnLike!.setTitle(likesTitle, for: .normal)
                    self.btnLike!.titleEdgeInsets = UIEdgeInsets(top: -2, left: 0, bottom: 0, right: 0)
                }
            }
        }
    }
    
    fileprivate var p_isLiked: Bool = false
    var isLiked: Bool {get { return self.p_isLiked }
        set {
            self.p_isLiked = newValue
            if (self.btnLike != nil) {
                if (!self.p_isLiked) {
                    let normalImage = UIImage.fontAwesomeIcon(name: .heart, textColor: UIColor.lightGray, size: CGSize(width: 64, height: 64))
                    self.btnLike!.setBackgroundImage(normalImage, for: .normal)
                } else {
                    let normalImage = UIImage.fontAwesomeIcon(name: .heart, textColor: UIColor(red: 0.7, green: 0.0, blue: 0.0, alpha: 1.0), size: CGSize(width: 64, height: 64))
                    self.btnLike!.setBackgroundImage(normalImage, for: .normal)
                }
            }
        }
    }
    
    fileprivate var p_message: String?
    var message: String? { get {
            return self.p_message
        }
        set {
            self.p_message = newValue
            self.p_urlRanges = [NSRange]()
            self.p_urls = [URL]()
            if (self.messageLabel != nil) {
                if (self.p_message != nil) {
                    let attrString = NSMutableAttributedString(string: self.p_message!, attributes:[NSFontAttributeName: self.messageLabel!.font!])
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    detector.enumerateMatches(in: self.p_message!, options: [], range: NSRange(self.p_message!.startIndex..<self.p_message!.endIndex, in: self.p_message!), using: { (url, _, _) in
                        if (url != nil) {
                            attrString.addAttribute(NSForegroundColorAttributeName, value: (self.p_urls.count == self.p_touchedUserIndex ? UIColor.lightGray : UIColor(red: 58.0/255.0, green: 128.0/255.0, blue: 238.0/255.0, alpha: 1)), range: url!.range)
                            self.p_urlRanges.append(url!.range)
                            self.p_urls.append(url!.url!)
                        }
                    })
                    self.messageLabel?.attributedText = attrString
                } else {
                    self.messageLabel?.attributedText = nil
                }
            }
        }
    }
    
    fileprivate var p_date: String?
    var date: String? { get {
            return self.p_date
        }
        set {
            self.p_date = newValue
            if (self.dateLabel != nil) {
                self.dateLabel?.text = self.p_date
            }
        }
    }
    
    var autosizeOpponents: Bool {
        get {
            if (self.whereMaxHeightConstraint != nil) {
                return (self.whereMaxHeightConstraint!.constant > 1990)
            }
            return false
        }
        set {
            if (self.defWhereOriginalHeight == nil) {
                self.defWhereOriginalHeight = self.whereMaxHeightConstraint!.constant
            }
            if (newValue) {
                self.whereMaxHeightConstraint!.constant = 2000
            } else {
                let ratio = UIScreen.main.bounds.width / 414.0
                self.whereMaxHeightConstraint!.constant = self.defWhereOriginalHeight! * ratio
            }
        }
    }
    
    var autosizeMessage: Bool {
        get {
            if (self.bodyMaxHaightConstraint != nil) {
                return (self.bodyMaxHaightConstraint!.constant > 1990)
            }
            return false
        }
        set {
            if (self.defBodyOriginalHeight == nil) {
                self.defBodyOriginalHeight = self.bodyMaxHaightConstraint!.constant
            }
            if (newValue) {
                self.bodyMaxHaightConstraint!.constant = 2000
            } else {
                let ratio = UIScreen.main.bounds.width / 414.0
                self.bodyMaxHaightConstraint!.constant = self.defBodyOriginalHeight! * ratio
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()

        if (self.p_needAutoresize) {
            self.p_needAutoresize = false
            self.autosizeOpponents = true
            self.autosizeMessage = true
        }
        
        let ratio = UIScreen.main.bounds.width / 414.0
        if (self.btnAvatar != nil) {
            self.btnAvatar!.clipsToBounds = true
            self.btnAvatar!.layer.cornerRadius = self.btnAvatar!.bounds.height * 0.49
            if (self.cAvatarLeft != nil) {
                self.cAvatarLeft!.constant = self.defCAvatarLeft * ratio
            }
        }
        if (self.btnJoin != nil) {
            self.btnJoin!.clipsToBounds = true
            switch (self.p_buttonType) {
            case .leave:
                let normalImage = UIImage.fontAwesomeIcon(name: .minusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
                self.btnJoin!.setImage(normalImage, for: .normal)
                self.btnJoin!.setTitle("Leave", for: .normal)
                self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize - 3)
                break
            case .join:
                let normalImage = UIImage.fontAwesomeIcon(name: .plusCircle, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
                self.btnJoin!.setImage(normalImage, for: .normal)
                self.btnJoin!.setTitle("Join", for: .normal)
                self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize)
                break
            case .edit:
                let normalImage = UIImage.fontAwesomeIcon(name: .pencil, textColor: UIColor.white, size: CGSize(width: 16, height: 16))
                self.btnJoin!.setImage(normalImage, for: .normal)
                self.btnJoin!.setTitle("Edit", for: .normal)
                self.btnJoin!.titleLabel!.font = self.btnJoin!.titleLabel!.font.withSize(self.defBJoinFontSize)
                
            }
            if (self.cJoinRight != nil) {
                self.cJoinRight!.constant = self.defCJoinRight * ratio
            }
            if (self.cJoinHeight != nil) {
                self.cJoinHeight!.constant = self.defCJoinHeight * ratio
                self.btnJoin!.cornerRadius = self.cJoinHeight!.constant * 0.49
            } else {
                self.btnJoin!.cornerRadius = self.btnJoin!.bounds.height * 0.49
            }
        }
        
        if (self.btnLike != nil) {
            self.likes = self.p_likesCount
            self.isLiked = self.p_isLiked
            if (self.cLikeWidth != nil) {
                self.cLikeWidth!.constant = self.defCLikeWidth * ratio
            }
        }
        
        if (self.btnMessage != nil) {
            let normalImage = UIImage.fontAwesomeIcon(name: .comment, textColor: UIColor.lightGray, size: CGSize(width: 64, height: 64))
            self.btnMessage!.setBackgroundImage(normalImage, for: .normal)
            if (self.cMessageWidth != nil) {
                self.cMessageWidth!.constant = self.defCMessageWidth * ratio
            }
        }
        
        if (self.cAvatarLeft != nil) {
            self.cAvatarLeft!.constant = self.defCAvatarLeft * ratio
        }
        if (self.cOpponentsRight != nil) {
            self.cOpponentsRight!.constant = self.defCOpponentsLabelRight * ratio
        }
        
        super.layoutSubviews()
    }
    
    
    @IBAction func onMessagePressed() {
        if (self.onComments != nil) {
            self.onComments!(self.workoutInfo)
        }
    }
    
    @IBAction func onLikePressed() {
        if (self.onLike != nil) {
            self.onLike!(self.workoutInfo)
        }
    }
    
    @IBAction func onJoinPressed() {
        switch (self.p_buttonType) {
        case .leave:
            self.onLeave?(self.workoutInfo)
            break
        
        case .join:
            self.onJoin?(self.workoutInfo)
            break
            
        case .edit:
            self.onEdit?(self.workoutInfo)
            break
        }
        
    }
    
    @IBAction func onCommentsPressed() {
        if (self.onComments != nil) {
            self.onComments!(self.workoutInfo)
        }
    }

    @IBAction func onAvatarPressed() {
        self.onAvatar?(self.workoutInfo)
    }
    
    @IBAction func onWherePressed() {
        self.onWhere?(self, self.workoutInfo)
    }
    
    @IBAction func onBodyPressed() {
        self.onBody?(self, self.workoutInfo)
    }
}

extension WorkoutCell {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if (touches.count == 1 && self.p_touch == nil) {
            let touch = touches.first!
            let location = touch.location(in: self.opponentsLabel!)
            
            if (self.opponentsLabel!.bounds.contains(location)) {
                self.p_touch = touch
                
                if let index = self.opponentsLabel!.indexOfSymbolAtPoint(location) {
                    if (self.opponentsLabel!.sizeThatFits(self.opponentsLabel!.bounds.size).height > self.opponentsLabel!.bounds.height) {
                        if (!self.autosizeOpponents) {
                            return
                        }
                    }
                    for (userIndex, opponentRange) in self.p_opponentsRanges.enumerated() {
                        //   for rect in opponentRects {
                        if (opponentRange.contains(index)) {
                            self.p_touch = touch
                            self.p_touchedUserIndex = userIndex
                            self.setOpponentsString()
                            self.layoutSubviews()
                            break
                        }
                        //   }
                    }
                    if (self.p_touchedUserIndex == -1) {
                        //   for rect in self.p_writerRects {
                        if (self.p_writerRange.contains(index)) {
                            self.p_touch = touch
                            self.p_touchedUserIndex = -100
                            self.setOpponentsString()
                            self.layoutSubviews()
                            //       break
                        } else if (self.p_addressRange.contains(index)) {
                            self.p_touch = touch
                            self.p_touchedUserIndex = -200
                            self.setOpponentsString()
                            self.layoutSubviews()
                        }
                    }
                }
            } else {
                let location = touch.location(in: self.messageLabel!)
                
                if (self.messageLabel!.bounds.contains(location)) {
                    self.p_touch = touch
                    
                    if let index = self.messageLabel!.indexOfSymbolAtPoint(location) {
                        for (urlIndex, urlRange) in self.p_urlRanges.enumerated() {
                            if (urlRange.contains(index)) {
                                self.p_touch = touch
                                self.p_touchedUserIndex = urlIndex
                                self.message = self.p_message
                                self.layoutSubviews()
                                break
                            }
                        }
                    }
                }
            }



        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if (self.p_touch != nil) {
            if (touches.contains(self.p_touch!)) {
                let location = self.p_touch!.location(in: self.opponentsLabel!)
                if (self.opponentsLabel!.bounds.contains(location)) {
                    var index = self.opponentsLabel?.indexOfSymbolAtPoint(location)
                    if (!self.autosizeOpponents && self.opponentsLabel!.sizeThatFits(self.opponentsLabel!.bounds.size).height > self.opponentsLabel!.bounds.height) {

                        index = -1
                    }
                    if (self.p_touchedUserIndex >= 0 && self.p_opponents != nil && self.p_touchedUserIndex < self.p_opponents!.count) {
                        let opponentRange = self.p_opponentsRanges[self.p_touchedUserIndex]
                        if (opponentRange.contains(index)) {
                            NSLog("User tapped: \(self.p_opponents![self.p_touchedUserIndex])")
                            self.onUserTapped?(self.p_opponents![self.p_touchedUserIndex])
                            self.p_touch = nil
                            self.p_touchedUserIndex = -1
                            self.setOpponentsString()
                            self.layoutSubviews()
                            return
                        }
                    } else if (self.p_touchedUserIndex == -100) {
                        if (self.p_writerRange.contains(index!)) {
                            NSLog("Writer tapped: \(self.workoutInfo?.organizer_name)")
                            self.onUserTapped?(self.workoutInfo?.organizer_name)
                            self.p_touch = nil
                            self.p_touchedUserIndex = -1
                            self.setOpponentsString()
                            self.layoutSubviews()
                            return
                        }
                    } else if (self.p_touchedUserIndex == -200) {
                        if (self.p_addressRange.contains(index!)) {
                            NSLog("Address tapped: \(self.p_location)")
                            self.onAddressTapped?(self.p_location)
                            self.p_touch = nil
                            self.p_touchedUserIndex = -1
                            self.setOpponentsString()
                            self.layoutSubviews()
                            return
                        }
                    }
                    self.p_touch = nil
                    self.p_touchedUserIndex = -1
                    self.setOpponentsString()
                    self.layoutSubviews()
                    
                    self.onWherePressed()
                } else {
                    let location = self.p_touch!.location(in: self.messageLabel!)
                    let index = self.messageLabel?.indexOfSymbolAtPoint(location)
                    if (self.p_touchedUserIndex >= 0 && self.p_touchedUserIndex < self.p_urls.count) {
                        let urlRange = self.p_urlRanges[self.p_touchedUserIndex]
                        if (urlRange.contains(index)) {
                            NSLog("URL tapped: \(self.p_urls[self.p_touchedUserIndex])")
                            self.onURLTapped?(self.p_urls[self.p_touchedUserIndex])
                        } else {
                            self.onBodyPressed()
                        }
                    } else {
                        self.onBodyPressed()
                    }
                    self.p_touch = nil
                    self.p_touchedUserIndex = -1
                    self.message = self.p_message
                    self.layoutSubviews()
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if (self.p_touch != nil) {
            if (touches.contains(self.p_touch!)) {
                self.p_touch = nil
                NSLog("Cancel touch \(self.p_touchedUserIndex)")
                self.p_touchedUserIndex = -1
                self.setOpponentsString()
                self.message = self.p_message
                self.layoutSubviews()
            }
        }
    }
}

extension WorkoutCell {
    
    func fullHeight(writer: String?, location: String?, opponents: [String]?, message: String?, commentsCount: Int, autosizeOpponents: Bool, autosizeMessage: Bool, workout: WorkoutInfo?) -> CGFloat {
        let ratio = UIScreen.main.bounds.width / 414.0
        let width = UIScreen.main.bounds.width - self.defCAvatarLeft * ratio - (self.cAvatarWidth?.constant ?? 0) - /*(self.cAvatarToOpponentsSpace?.constant ?? 0) -*/ self.defCOpponentsLabelRight * ratio//???
        var defHeight : CGFloat = /*self.opponentsLabel!.frame.minY*/27 + 8 + 6 //V: Opp<-8->Mess<-6->Join
        defHeight += self.defCJoinHeight * ratio
        if (commentsCount == 0) {
            defHeight += 35//35
        } else {
            defHeight += 71//71
        }
        var messageHeight = (message ?? "").sizeWithFont(self.messageLabel!.font, forWidth: width).height + 2
        if (!autosizeMessage) {
            if (messageHeight > self.defBodyOriginalHeight!/* * ratio*/) {
                messageHeight = self.defBodyOriginalHeight!/* * ratio*/
            }
        }
        self.p_writer = writer
        UsersManager.shared.getUser(userName: self.p_writer, completed: { (user:UserInfo) in
            self.p_users[user.username] = user
        })
        self.p_location = location
        self.workoutInfo = workout
        self.opponents = opponents
        var opponentsHeight: CGFloat = 0
        if (self.opponentsLabel != nil && self.opponentsLabel!.attributedText != nil) {
            opponentsHeight = self.opponentsLabel!.attributedText!.sizeForWidth(forWidth: width).height + 1
            if (!autosizeOpponents) {
                if (opponentsHeight > self.defWhereOriginalHeight!/* * ratio*/) {
                    opponentsHeight = self.defWhereOriginalHeight!/* * ratio*/
                }
            }
        }
        return defHeight + messageHeight + opponentsHeight
    }
    
}
