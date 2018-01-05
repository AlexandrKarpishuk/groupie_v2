//
//  UIImageExt.swift
//  groupie
//
//  Created by Sania on 8/29/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    func resize(to size:CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        guard UIGraphicsGetCurrentContext() != nil else { return nil }
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}
