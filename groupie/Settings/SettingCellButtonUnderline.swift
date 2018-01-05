//
//  SettingCellButton.swift
//  groupie
//
//  Created by Sania on 8/13/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class SettingsCellButtonUnderline : UITableViewCell {
    
    @IBOutlet var button: UIButton!
    
    var onButtonPressed: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let oldTitle = self.button.title(for: .normal)
        let attrTitle = NSAttributedString(string: oldTitle!,
                                           attributes: [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        self.button.setAttributedTitle(attrTitle, for: .normal)
    }
    
    @IBAction func onButtonTouchUpInside(_ sender: AnyObject?) {
        if (self.onButtonPressed != nil) {
            self.onButtonPressed!()
        }
    }
}
