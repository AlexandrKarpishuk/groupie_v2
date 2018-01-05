//
//  LoginAnimationView.swift
//  groupie
//
//  Created by Sania on 8/6/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class LoginAnimationView : UIScrollView {
    
    @IBOutlet var firstView: LoginAnimationItem!
    @IBOutlet var secondView: LoginAnimationItem!
    @IBOutlet var thirdView: LoginAnimationItem!
    @IBOutlet var fourthView: LoginAnimationItem!
    @IBOutlet var fifthView: LoginAnimationItem!
    
    var onAnimationCompleted: (()->Void)?
    
    func startAnimation() {
        
    }
    
}
