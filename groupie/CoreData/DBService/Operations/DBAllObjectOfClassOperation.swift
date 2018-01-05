//
//  DBAllObjectOfClassOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBAllObjectOfClassOperation : DBBaseOperation {
    
    var classDescription : NSEntityDescription?
    var finishedWithArray: ((NSArray)->Void)?
    var filter : String?
    var sortField : String?
    var ascending : Bool?
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        if (self.classDescription != nil)
        {
            let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>()
            fetchRequest.entity = self.classDescription
            if self.filter != nil {
                let predicate = NSPredicate(format:self.filter!, argumentArray: nil)
                fetchRequest.predicate = predicate
            }
            if (self.sortField != nil) {
                var ask = self.ascending
                if (ask == nil) {
                    ask = true
                }
                let sortDescriptor = NSSortDescriptor(key:self.sortField, ascending: ask!)
                fetchRequest.sortDescriptors = [sortDescriptor]
            }
            
            do {
                let result = try self.dbContext!.fetch(fetchRequest)
                if (self.isCancelled == true) {
                    return
                }
                if (self.finishedWithArray != nil) {
                    self.finishedWithArray!(result as NSArray)
                }
                if (self.operationDidFinish != nil) {
                    self.operationDidFinish!(nil)
                }
                return
            } catch let error {
                if (self.isCancelled == true) {
                    return
                }
                if (self.finishedWithArray != nil) {
                    self.finishedWithArray!([])
                }
                if (self.operationDidFinish != nil) {
                    self.operationDidFinish!(error)
                }
                return
            }
        }

        if (self.isCancelled == true) {
            return
        }
        if (self.finishedWithArray != nil) {
            self.finishedWithArray!([])
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(NSError(domain: "Can't find description for class", code: 4001, userInfo: nil))
        }
    }
}
