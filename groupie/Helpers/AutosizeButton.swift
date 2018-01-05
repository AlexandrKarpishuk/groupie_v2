//
//  AutosizeButton.swift
//  groupie
//
//  Created by Sania on 6/7/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class AutosizeButton : UIButton {
    
    var m_minFontSize : CGFloat = 2.0
    private var p_maxFontSize : CGFloat?
    private var p_needAutosize = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (self.p_maxFontSize == nil) {
            self.p_maxFontSize = self.titleLabel!.font.pointSize
        }
        if (self.p_needAutosize == true) {
            self.p_needAutosize = false
            self.autosizeLabel()
            self.p_needAutosize = true
        }
    }
    
    func autosizeLabel() {
        var textSize = self.titleLabel?.sizeThatFits(CGSize(width: Int(INT_MAX), height: Int(INT_MAX)))
        //   let titl = self.titleLabel?.text
        while textSize!.width > self.frame.size.width {
            let oldFontSize = self.titleLabel?.font.pointSize
            
            if (oldFontSize! <= self.m_minFontSize) {
                break
            }
            
            self.titleLabel?.font = self.titleLabel!.font.withSize(oldFontSize! - 1.0)
            
            textSize = self.titleLabel?.sizeThatFits(CGSize(width: Int(INT_MAX), height: Int(INT_MAX)))
        }
        
        while textSize!.width < self.frame.size.width {
            let oldFontSize = self.titleLabel?.font.pointSize
            
            if (oldFontSize! >= self.p_maxFontSize!) {
                break
            }
            
            self.titleLabel?.font = self.titleLabel!.font.withSize(oldFontSize! + 1.0)
            
            textSize = self.titleLabel?.sizeThatFits(CGSize(width: Int(INT_MAX), height: Int(INT_MAX)))
            
            if (textSize!.width > self.frame.size.width) {
                self.titleLabel?.font = self.titleLabel!.font.withSize(oldFontSize!)
            }
        }
        
        self.layoutIfNeeded()
    }
}
