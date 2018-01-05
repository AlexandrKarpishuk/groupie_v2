//
//  InviteFriendsCell.swift
//  groupie
//
//  Created by Sania on 8/18/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class InviteFriendsCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutsLabel: UILabel!
    @IBOutlet weak var emailsLabel: UILabel!
    @IBOutlet weak var phonesLabel: UILabel!
    @IBOutlet weak var isFollowing: RoundedButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height * 0.49
        self.isFollowing.cornerRadius = 2.7
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.workoutsLabel.text = nil
        self.emailsLabel.text = nil
        self.phonesLabel.text = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.workoutsLabel.text = nil
        self.emailsLabel.text = nil
        self.phonesLabel.text = nil
    }
    
    func SetSelected(_ selected: Bool) {
        self.checkBox.isHighlighted = false
        
        if (selected) {
            self.checkBox.image = UIImage(named: "CheckBox_Checked")
        } else {
            self.checkBox.image = UIImage(named: "CheckBox_Unchecked")
        }
    }
}
