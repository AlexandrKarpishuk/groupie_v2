//
//  UIColorExt.swift
//  Groupie
//
//  Created by Sania on 10/19/17.
//  Copyright © 2017 Sania. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(r:UInt8, g:UInt8, b:UInt8, a:UInt8 = 255) {
        self.init(red:CGFloat(r)/255.0, green:CGFloat(g)/255.0, blue:CGFloat(b)/255.0, alpha:CGFloat(a)/255.0)
    }
    
    func colorWithAlpha(_ a: UInt8) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var tmpAlpha: CGFloat = 0
        let _ = self.getRed(&red,
                                     green: &green,
                                     blue: &blue,
                                     alpha: &tmpAlpha)
        return UIColor(red: red, green: green, blue: blue, alpha: CGFloat(a)/255.0)
    }
}
