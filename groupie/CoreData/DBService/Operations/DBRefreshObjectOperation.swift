//
//  DBRefreshObjectOperation.swift
//
//  Created by Sania on 05/11/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBRefreshObjectOperation : DBBaseOperation {
    
    var objectsForRefresh : NSArray?
    
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        if (self.dbContext != nil && self.objectsForRefresh != nil) {
            for object in self.objectsForRefresh! {
                self.dbContext?.refresh(object as! NSManagedObject, mergeChanges: true)
            }
        }
        
        if (self.isCancelled == true) {
            return
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
        
    }
    
}
