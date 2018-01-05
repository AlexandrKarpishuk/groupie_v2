//
//  POST_Place_Cell.swift
//  groupie
//
//  Created by Sania on 8/9/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class POST_View_Cell : UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var isFollowing: RoundedButton?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (self.isFollowing != nil) {
            self.isFollowing?.cornerRadius = 2.7
        }
    }
}
