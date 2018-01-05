//
//  SearchFriendsCell.swift
//  groupie
//
//  Created by Sania on 6/16/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class SearchFriendsCell: UITableViewCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var workoutsLabel: UILabel!
    @IBOutlet weak var isFollowing: RoundedButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.avatarView.bounds.height * 0.49
        
        self.isFollowing.cornerRadius = 2.7
    }
    
}
