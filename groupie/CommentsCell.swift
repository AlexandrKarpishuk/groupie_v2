//
//  CommentsCell.swift
//  groupie
//
//  Created by Sania on 7/5/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome_swift

class CommentsCell : UITableViewCell {
    
    
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var messageView: UITextView!
    
    @IBOutlet var btnDelete: UIButton!
    
    @IBOutlet var messageBottomConstraint: NSLayoutConstraint!
    @IBOutlet var cBtnDeleteLeft: NSLayoutConstraint!
    
    var comment: CommentInfo?
    var onDeleteHandler:((CommentInfo?)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.btnDelete.setImage(UIImage.fontAwesomeIcon(name: FontAwesome.trashO, textColor: UIColor.lightGray, size: CGSize(width:20, height:20)), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.messageView.text = ""
        self.messageView.attributedText = NSAttributedString(string: "")
        
        self.btnDelete.isHidden = true
    }
    
    @IBAction func onDeleteTouchUpInside() {
        self.onDeleteHandler?(self.comment)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height * 0.49
        
        self.messageView.setNeedsLayout()
        self.messageView.layoutIfNeeded()
        self.cBtnDeleteLeft.constant = self.messageView.rectOfLastChar().maxX + 8
    }
}
