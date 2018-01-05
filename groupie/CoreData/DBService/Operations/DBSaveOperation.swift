//
//  DBSaveOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation

class DBSaveOperation : DBBaseOperation {
    
    override func main() {
        if self.dbContext != nil {
            var error: NSError? = nil
            if self.dbContext!.hasChanges {
                do {
                    try self.dbContext!.save()
                } catch let error1 as NSError {
                    error = error1
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog("Unresolved error \(error), \(error!.userInfo)")
                    if (self.operationDidFinish != nil) {
                        self.operationDidFinish!(error)
                    }
                    abort()
                }
            }
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
    }
    
}