//
//  NSRangeExt.swift
//  groupie
//
//  Created by Sania on 9/1/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

extension NSRange {
    
    func contains(_ index: Int?) -> Bool {
        if (index != nil) {
            return (index! >= self.location && index! < self.location + self.length)
        }
        return false
    }
    
}
