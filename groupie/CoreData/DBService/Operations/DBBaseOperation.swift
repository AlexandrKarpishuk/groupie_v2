//
//  DBBaseOperation.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData

class DBBaseOperation : Operation {
    
    var operationDidFinish : ((Error?) -> Void)?
    
    fileprivate(set) internal var dbContext : NSManagedObjectContext?
    fileprivate(set) internal var dbModel : NSManagedObjectModel?
    fileprivate(set) internal var dbCoordinator : NSPersistentStoreCoordinator?
    
    convenience init (context:NSManagedObjectContext, model:NSManagedObjectModel? = nil, coordinator:NSPersistentStoreCoordinator? = nil) {
        self.init()
        
        self.dbContext = context
        self.dbModel = model
        self.dbCoordinator = coordinator
    }
    
}
