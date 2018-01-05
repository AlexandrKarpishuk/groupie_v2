//
//  DBDeleteAllObjectOfClassOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBDeleteAllObjectOfClassOperation : DBBaseOperation {
    
    var classDescription : NSEntityDescription?
    
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        if (self.dbContext != nil && self.classDescription != nil) {
            let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>()
            fetchRequest.entity = self.classDescription
            
            do {
                let result = try self.dbContext!.fetch(fetchRequest)

                for object in result {
                    if (self.isCancelled == true) {
                        return
                    }
                    self.dbContext!.delete(object)
                }


            } catch let error {
                if (self.isCancelled == true) {
                    return
                }
                if (self.operationDidFinish != nil) {
                    self.operationDidFinish!(error)
                }
                return
            }

        }
        
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
        
    }
    
}
