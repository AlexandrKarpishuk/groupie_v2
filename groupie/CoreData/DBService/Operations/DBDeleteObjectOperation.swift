//
//  DBDeleteObjectOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBDeleteObjectOperation : DBBaseOperation {
    
    var objectForDelete : NSManagedObject?
    
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        if (self.dbContext != nil && self.objectForDelete != nil) {
            self.dbContext?.delete(self.objectForDelete!)
        }
        
        if (self.isCancelled == true) {
            return
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
        
    }
}
