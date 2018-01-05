//
//  SettingCellTextField.swift
//  groupie
//
//  Created by Sania on 8/31/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class SettingCellTextField : UITableViewCell {
    @IBOutlet var field: UITextField!
    @IBOutlet var lTitle: UILabel!
    
    var onEnterPressed: ((_ text:String?)->Void)?
    
    
}

extension SettingCellTextField : UITextFieldDelegate {


    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            self.field.resignFirstResponder()
            self.onEnterPressed?(self.field.text)
            return false
        }
        return true
    }
    
}

