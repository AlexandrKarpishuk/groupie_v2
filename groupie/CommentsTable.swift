//
//  CommentsTable.swift
//  groupie
//
//  Created by Sania on 7/6/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation
import UIKit

class CommentsTable: UITableView {
    
    var didLayout: (()->Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    //    NSLog("Isents: \(self.contentInset)")
        if (self.didLayout != nil) {
            self.didLayout!()
        }
    }
    
}
