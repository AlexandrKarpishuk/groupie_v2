//
//  StringExt.swift
//  groupie
//
//  Created by Sania on 8/25/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func isEmail() -> Bool {
        if (!self.isEmpty) {
            let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: self)
        }
        return false
    }
    
    func isPhoneNumber() -> Bool {
        var tmpPhoneNumberSet = CharacterSet(charactersIn:self)
        tmpPhoneNumberSet.subtract(CharacterSet(charactersIn: " +()-"))
        if (!tmpPhoneNumberSet.isEmpty) {
            return tmpPhoneNumberSet.isSubset(of: CharacterSet.decimalDigits)
        }
        return false
    }
    
    func getPhoneNumber() ->String {
        var tmpNumber = self
        while let tmpRange = tmpNumber.rangeOfCharacter(from: CharacterSet(charactersIn:" +()-")) {
            tmpNumber.removeSubrange(tmpRange)
        }
        if (tmpNumber.count == 7) {
            return "+1212" + tmpNumber
        }
        if (tmpNumber.count == 10) {
            return "+1" + tmpNumber
        }
        return "+" + tmpNumber
    }
    
    func sizeWithFont(_ font: UIFont, forWidth: CGFloat) -> CGSize {
        /*let storage = NSTextStorage(string: self)
        let container = NSTextContainer(size: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
        storage.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: storage.length))
        
        container.lineBreakMode = .byWordWrapping
        container.maximumNumberOfLines = 0
        container.lineFragmentPadding = 5.0
        
        layoutManager.glyphRange(for: container)
        return layoutManager.usedRect(for: container).size*/
        
        let attrString = NSAttributedString(string: self, attributes: [NSFontAttributeName : font])
        return attrString.boundingRect(with: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
    }
}

extension NSAttributedString {
    func sizeForWidth(forWidth: CGFloat) -> CGSize {
   /*     let storage = NSTextStorage(attributedString: self)
        let container = NSTextContainer(size: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(container)
        storage.addLayoutManager(layoutManager)
     //   storage.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: storage.length))
        
        container.lineBreakMode = .byWordWrapping
        container.maximumNumberOfLines = 0
        container.lineFragmentPadding = 4.0
        
        layoutManager.glyphRange(for: container)
        return layoutManager.usedRect(for: container).size*/
        return self.boundingRect(with: CGSize(width: forWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesFontLeading, .usesLineFragmentOrigin], context: nil).size
    }
}
