//
//  WorkoutListCell.swift
//  groupie
//
//  Created by Xinran on 4/24/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit

class WorkoutListCell: UITableViewCell{
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var workoutTypeLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    @IBOutlet weak var addressLabel: UILabel?
    @IBOutlet weak var addButton: UIButton?
    
    fileprivate let timeFont = UIFont(name: "OpenSans-Semibold", size: 12)
    fileprivate let dateFont = UIFont(name: "OpenSans-Regular", size: 12)
    fileprivate let workoutTypeFont = UIFont(name: "OpenSans-Semibold", size: 9)
    fileprivate let nameFont = UIFont(name: "OpenSans-Regular", size: 16)
    fileprivate let descFont = UIFont(name: "OpenSans-Light", size: 13)
    fileprivate let addressFont = UIFont(name: "OpenSans-Regular", size: 12)
    
    fileprivate let color1 = UIColor(red: 60/255, green: 67/255, blue: 80/255, alpha: 1)
    fileprivate let color2 = UIColor(red: 157/255, green: 161/255, blue: 167/255, alpha: 1)
    fileprivate let color3 = UIColor(red: 234/255, green: 172/255, blue: 84/255, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()

        timeLabel?.font = timeFont
        dateLabel?.font = dateFont
        workoutTypeLabel?.font = workoutTypeFont
        nameLabel?.font = nameFont
        descriptionLabel?.font = descFont
        addressLabel?.font = addressFont
        
        timeLabel?.textColor = color1
        dateLabel?.textColor = color2
        workoutTypeLabel?.textColor = color3
        nameLabel?.textColor = color1
        descriptionLabel?.textColor = color2
        addressLabel?.textColor = color2
    }
}
