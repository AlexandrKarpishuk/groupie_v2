//
//  DBOpenOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBOpenOperation : Operation {
    
    fileprivate var p_dbFileName : String?
    fileprivate var p_dbModelFileName : String?
    
    var modelDidCreated : ((NSManagedObjectModel) -> Void)?
    var coordinatorDidCreated : ((NSPersistentStoreCoordinator) -> Void)?
    var contextDidCreated : ((NSManagedObjectContext) -> Void)?
    var didFinished: ((NSError?)->Void)?
    
    convenience init(dbFileName:String, dbModelFileName:String) // name without extension
    {
        self.init()
        
        self.p_dbFileName = dbFileName
        self.p_dbModelFileName = dbModelFileName
    }
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        
        // Create model
        let modelURL = Bundle.main.url(forResource: self.p_dbModelFileName, withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        if (self.isCancelled == true) {
            return
        }
        if (self.modelDidCreated != nil) {
            self.modelDidCreated!(model)
        }
        if (self.isCancelled == true) {
            return
        }

        // Create coordinator
        // Create the coordinator and store
        var coordinator : NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: model)
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.last!.appendingPathComponent(self.p_dbFileName!).appendingPathExtension("sqlite")
        var error: NSError? = nil
        let failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType,
                    configurationName: nil,
                    at: url,
                    options: [NSMigratePersistentStoresAutomaticallyOption: true,
                              NSInferMappingModelAutomaticallyOption: true])
        } catch let error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        if (self.isCancelled == true) {
            return
        }
        if (self.coordinatorDidCreated != nil) {
            self.coordinatorDidCreated!(coordinator!)
        }
        if (self.isCancelled == true) {
            return
        }
        
        // Create Context
        if (self.contextDidCreated != nil) {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            if coordinator != nil {
                let context = NSManagedObjectContext()
                context.persistentStoreCoordinator = coordinator!
                
                if (self.isCancelled == true) {
                    return
                }
                self.contextDidCreated!(context)
            }

        }
        
        if (self.didFinished != nil) {
            self.didFinished!(error)
        }
    }
    
}
