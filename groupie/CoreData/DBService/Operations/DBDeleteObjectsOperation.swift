//
//  DBDeleteObjectsOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBDeleteObjectsOperation : DBBaseOperation {
    
    var objectsForDelete : NSArray?
    
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        if (self.dbContext != nil && self.objectsForDelete != nil) {
            for object in objectsForDelete! {
                let tmpObject = object as! NSManagedObject
                self.dbContext!.delete(tmpObject)
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
