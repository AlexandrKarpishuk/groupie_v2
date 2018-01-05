//
//  SettingsCellSwitch.swift
//  groupie
//
//  Created by Sania on 8/20/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class SettingCellSwitch : UITableViewCell {
    
    @IBOutlet var swOnOff: UISwitch!
    
    var onSwitchChanged: ((_ state:Bool)->Void)?
    
    
    @IBAction func onSwitchValueChanged(_ sender: UISwitch?) {
        if (self.onSwitchChanged != nil) {
            self.onSwitchChanged!(sender!.isOn)
        }
    }
    
}
