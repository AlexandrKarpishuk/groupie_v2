//
//  DBService.swift
//
//  Created by Sania on 31/10/15.
//  Copyright © 2015 Sania. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class DBService : NSObject {
    
    static var shared : DBService = DBService()
    
    static var IS_OPENED_NOTIFICATION = NSNotification.Name("DBServiceDataBaseIsOpenedNotification")
    
//MARK: - Private
    fileprivate var p_modelFileName : String?
    fileprivate var p_dataBaseName : String?
    fileprivate lazy var p_operationQueue : OperationQueue = {
        let queue = OperationQueue()
        queue.name = "DBService CoreData Queue (Serial)"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    fileprivate var p_dbModel       : NSManagedObjectModel?
    fileprivate var p_dbCoordinator : NSPersistentStoreCoordinator?
    fileprivate var p_dbContext     : NSManagedObjectContext?
    fileprivate var p_dbEntitiesByName : [String : NSEntityDescription]?
    
//MARK: - DataBase
    func OpenDataBase(_ dataBaseName:String, modelFileName:String, completed:((Error?)->Void)? = nil) {
        self.CloseDataBase { (error:Error?) in
            if (error == nil) {
                self.p_modelFileName = modelFileName
                self.p_dataBaseName = dataBaseName
                
                let openOperation = DBOpenOperation(dbFileName: dataBaseName, dbModelFileName: modelFileName)
                openOperation.modelDidCreated = { (model:NSManagedObjectModel) -> Void in
                    self.p_dbModel = model
                    self.p_dbEntitiesByName = model.entitiesByName
                    
                    if (self.IsMigrationNeeded()) {
                        NSLog("Start migration")
                        
                        let srcStoreUrl = DOCUMENTS_URL().appendingPathComponent(self.p_dataBaseName!).appendingPathExtension("sqlite")
                        
                        if (!self.ProgressivelyMigrateURL(srcStoreUrl, type: NSSQLiteStoreType, finalModel: self.p_dbModel!)) {
                            NSLog("Migration FAIL!!!")
                        }
                    }
                }
                openOperation.coordinatorDidCreated = { (coordinator:NSPersistentStoreCoordinator) -> Void in
                    self.p_dbCoordinator = coordinator
                }
                openOperation.contextDidCreated = { (context:NSManagedObjectContext) -> Void in
                    self.p_dbContext = context
                    NotificationCenter.default.post(name: DBService.IS_OPENED_NOTIFICATION, object: nil)
                }
                openOperation.didFinished = completed
                self.p_operationQueue.addOperation(openOperation)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.OnEnterBackground(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
            }
        }
        

    }
    
    @objc func OnEnterBackground(_ notify:Notification) {
        self.SaveContext()
    }
    
    func CloseDataBase(_ didFinish:((Error?)->Void)? = nil) {
        NotificationCenter.default.removeObserver(self)
        if self.p_dbContext != nil {
            self.SaveContext { (error:Error?) -> Void in
                self.p_dbCoordinator = nil
                self.p_dbContext = nil
                self.p_dbModel = nil
                if (didFinish != nil) {
                    didFinish!(error)
                }
            }
        } else {
            if (didFinish != nil) {
                didFinish!(nil)
            }
        }
    }
    
    func SaveContext (_ didFinish:((Error?)->Void)? = nil) {
        if self.p_dbContext != nil {
            let saveOperation = DBSaveOperation(context: self.p_dbContext!)
            saveOperation.operationDidFinish = didFinish
            self.p_operationQueue.addOperation(saveOperation)
        } else {
            if (didFinish != nil) {
                didFinish!(nil)
            }
        }
    }
    
//MARK: - Objects
    fileprivate func ClassName(_ dstClass:NSObject.Type) -> String {
        let className = NSStringFromClass(dstClass)
        let range = className.range(of: ".")
        if range?.upperBound != range?.lowerBound {
            return className.substring(from: range!.upperBound)
        }
        return className
    }
    
    // NOT SAFETY!!!
    func CreateObjectFromCurrentThread(_ dstClass:NSObject.Type, info:NSDictionary? = nil) -> NSManagedObject {
        var result : NSManagedObject?
        if (info?["id"] == nil || self.DescriptionForClass(dstClass) == nil) {
            result = NSEntityDescription.insertNewObject(forEntityName: self.ClassName(dstClass), into: self.p_dbContext!)
        } else {
            var id : Int64?
            switch (info!["id"]) {
            case is NSNumber:
                id = Int64((info!["id"] as! NSNumber).intValue)
                break
            case is String:
                id = Int64(info!["id"] as! String)
                break
            case is NSString:
                id = Int64(info!["id"] as! String)
                break
            default:
                break
            }
            
            let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>()
            fetchRequest.entity = self.DescriptionForClass(dstClass)
            
            let filter = "id==\(id!)"
            let predicate = NSPredicate(format:filter, argumentArray: nil)
            fetchRequest.predicate = predicate
            
            var objectsInCoreData : [AnyObject]?
            do {
                objectsInCoreData = try self.p_dbContext!.fetch(fetchRequest)
            } catch {
            }
            
            if (objectsInCoreData?.count > 0) {
                result = objectsInCoreData!.first as? NSManagedObject
                
                objectsInCoreData!.removeFirst()
                for object in objectsInCoreData! {
                    let tmpObject = object as! NSManagedObject
                    self.p_dbContext!.delete(tmpObject)
                }
            } else {
                result = NSEntityDescription.insertNewObject(forEntityName: self.ClassName(dstClass), into: self.p_dbContext!)
            }
        }

        
        if (info != nil) {
            result!.initWithInfo(info! as NSDictionary)
        }
        return result!
    }
    
    // NOT SAFETY!!!
    func CreateObjectsFromCurrentThread(_ dstClass:NSObject.Type, infoArray:NSArray?) -> NSArray {
        let result = NSMutableArray()
        if (infoArray != nil) {
            for info in infoArray! {
                result.add(self.CreateObjectFromCurrentThread(dstClass, info:info as? NSDictionary))
            }
        }
        return result
    }
    
    func CreateObjectForClass(_ dstClass:NSObject.Type, info:NSDictionary? = nil, created:((NSManagedObject)->Void)?) {
        let createOperation = DBCreateObjectOperation(context: self.p_dbContext!)
        createOperation.classDescription = self.DescriptionForClass(dstClass)
        createOperation.objectInfo = info
        createOperation.finishedWithObject = created
        self.p_operationQueue.addOperation(createOperation)
    }
    
    func CreateObjectsForClass(_ dstClass:NSObject.Type, infoArray:NSArray?, created:((NSArray)->Void)?) {
        if (self.p_dbContext != nil) {
            let createOperation = DBCreateObjectsOperation(context: self.p_dbContext!)
            createOperation.classDescription = self.DescriptionForClass(dstClass)
            createOperation.objectInfoArray = infoArray
            createOperation.finishedWithArray = created
            self.p_operationQueue.addOperation(createOperation)
        } else {
            created?(NSArray())
        }
    }
    
    func DescriptionForClass(_ srcClass:NSObject.Type) -> NSEntityDescription? {
        return self.p_dbEntitiesByName?[self.ClassName(srcClass)]
    }
    
    func RemoveObject(_ object:NSManagedObject, completed:((Error?)->Void)? = nil) {
        if (self.p_dbContext != nil) {
            let removeOperation = DBDeleteObjectOperation(context: self.p_dbContext!)
            removeOperation.objectForDelete = object
            removeOperation.operationDidFinish = completed
            self.p_operationQueue.addOperation(removeOperation)
        } else {
            completed?(nil)
        }
    }
    
    // NOT SAFETY!!! You must use RemoveObject(::)!
    func RemoveObjectFromCurrentThread(_ object:NSManagedObject?) {
        if (object != nil) {
            self.p_dbContext?.delete(object!)
        }
    }
    
    func RemoveObjects(_ objectsArray:NSArray, completed:((Error?)->Void)? = nil) {
        if (self.p_dbContext != nil) {
            let removeOperation = DBDeleteObjectsOperation(context: self.p_dbContext!)
            removeOperation.objectsForDelete = objectsArray
            removeOperation.operationDidFinish = completed
            self.p_operationQueue.addOperation(removeOperation)
        } else {
            completed?(nil)
        }
    }
    
    func RemoveAllObjectsOfClass(_ srcClass:NSObject.Type, completed:((Error?)->Void)? = nil) {
        if (self.p_dbContext != nil) {
            let removeOperation = DBDeleteAllObjectOfClassOperation(context: self.p_dbContext!)
            removeOperation.classDescription = self.DescriptionForClass(srcClass)
            removeOperation.operationDidFinish = completed
            self.p_operationQueue.addOperation(removeOperation)
        } else {
            completed?(nil)
        }
    }
    
    func RefreshObjects(_ objects:NSArray, completed:((Error?)->Void)? = nil) {
        if (self.p_dbContext != nil) {
            let refreshOperation = DBRefreshObjectOperation(context: self.p_dbContext!)
            refreshOperation.objectsForRefresh = objects
            refreshOperation.operationDidFinish = completed
            self.p_operationQueue.addOperation(refreshOperation)
        } else {
            completed?(nil)
        }
    }
    
    // NOT SAFETY!!! Use AllObjectsOfClass(:::::)
    func AllObjectsFromCurrentThread(_ srcClass:NSObject.Type, filter:String? = nil, sortBy:String? = nil, ascending:Bool? = nil) -> NSArray {
        if (self.DescriptionForClass(srcClass) != nil)
        {
            let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>()
            fetchRequest.entity = self.DescriptionForClass(srcClass)
            if filter != nil {
                let predicate = NSPredicate(format:filter!, argumentArray: nil)
                fetchRequest.predicate = predicate
            }
            if (sortBy != nil) {
                var ask = ascending
                if (ask == nil) {
                    ask = true
                }
                let sortDescriptor = NSSortDescriptor(key:sortBy!, ascending: ask!)
                fetchRequest.sortDescriptors = [sortDescriptor]
            }
            
            do {
                let result = try self.p_dbContext!.fetch(fetchRequest)
                return result as NSArray
            } catch {
                NSLog("\(error)")
            }
        }
        return NSArray()
    }
    
    func AllObjectsOfClass(_ srcClass:NSObject.Type, filter:String? = nil, sortBy:String? = nil, ascending:Bool? = nil, completed:((NSArray?)->Void)? = nil) {
        if (self.p_dbContext != nil) {
            let allObjectsOperation = DBAllObjectOfClassOperation(context: self.p_dbContext!)
            allObjectsOperation.classDescription = self.DescriptionForClass(srcClass)
            allObjectsOperation.finishedWithArray = completed
            allObjectsOperation.filter = filter
            allObjectsOperation.sortField = sortBy
            allObjectsOperation.ascending = ascending
            self.p_operationQueue.addOperation(allObjectsOperation)
        } else {
            if (completed != nil) {
                completed?(NSArray())
            }
        }
    }
    
    func PerformBlockInDBQueue(_ dstBlock:@escaping (()->Void)) {
        let operation = BlockOperation.init(block:dstBlock)
        self.p_operationQueue.addOperation(operation)
    }
}

//MARK: - Private
extension DBService {
 
    
    fileprivate func SourceModelForSourceMetadata(_ sourceMetadata:[String:AnyObject]) -> NSManagedObjectModel? {
        return NSManagedObjectModel.mergedModel(from: [Bundle.main], forStoreMetadata:sourceMetadata)
    }
    
    fileprivate func ModelURLs() -> [URL] {
        let modelFolderURL = Bundle.main.url(forResource: self.p_modelFileName,  withExtension: "momd")!
        return Bundle.main.urls(forResourcesWithExtension: "mom", subdirectory: modelFolderURL.lastPathComponent)!
    }
    
    fileprivate func GetDestinationModel(forSourceModel sourceModel:NSManagedObjectModel) -> (model:NSManagedObjectModel?, mapping:NSMappingModel?, name:String?) {
        
        let modelsURLs = self.ModelURLs()
        for modelUrl in modelsURLs {
            let model = NSManagedObjectModel(contentsOf: modelUrl)
            let mapping = NSMappingModel(from: [Bundle.main],
                                         forSourceModel: sourceModel,
                                         destinationModel: model)
            if (mapping != nil) {
                return (model, mapping, modelUrl.deletingPathExtension().lastPathComponent)
            }
        }
        
        return (nil, nil, self.p_modelFileName)
    }
    
    fileprivate func DestinationStoreURLWithSourceStoreURL(_ sourceStoreURL:URL, modelName:String) -> URL {
        let storeExtension = sourceStoreURL.pathExtension
        let storeURL = sourceStoreURL.deletingLastPathComponent()
        return storeURL.appendingPathComponent(modelName).appendingPathExtension(storeExtension)
    }
    
    fileprivate func BackupSourceStoreAtURL(_ srcStoreURL:URL, dstStoreURL:URL) -> Bool {
        let guid = ProcessInfo.processInfo.globallyUniqueString
        let srcExtension = srcStoreURL.pathExtension
        let backupURL = CACHE_URL().appendingPathComponent(guid).appendingPathExtension(srcExtension)
        
        do {
            try (FileManager.default.moveItem(at: srcStoreURL, to: backupURL))
        } catch let error as NSObject {
            NSLog("Can't move to temporary folder!\nSrc:'\(srcStoreURL)'\nDst:'\(backupURL)'\nError: \(error)")
            return false
        }
        
        do {
            try (FileManager.default.moveItem(at: dstStoreURL, to: srcStoreURL))
        } catch {
            NSLog("Can't move new Store!\nSrc:'\(dstStoreURL)'\nDst:'\(dstStoreURL)'\nError: \(error)")
            do {
                try (FileManager.default.moveItem(at: backupURL, to:srcStoreURL))
            } catch {
                NSLog("Can't moveback backup!\nSrc:'\(backupURL)'\nDst:'\(srcStoreURL)'\nError: \(error)")
            }
            return false
        }
        
        return true
    }
    
    fileprivate func ProgressivelyMigrateURL(_ sourceStoreURL:URL, type:String, finalModel:NSManagedObjectModel) -> Bool {
        do {
            let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: sourceStoreURL, options: nil)
            
            if (finalModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)) {
                return true
            }
            
            let sourceModel = self.SourceModelForSourceMetadata(sourceMetadata as [String : AnyObject])
            let (destinationModel, mappingModel, modelName) = self.GetDestinationModel(forSourceModel: sourceModel!)
            if (destinationModel == nil || mappingModel == nil) {
                NSLog("Can't find mapping model for '\(String(describing: modelName))'")
                return false
            }
            
            let destStoreURL = self.DestinationStoreURLWithSourceStoreURL(sourceStoreURL, modelName: modelName!)
            
            let migrationManager = NSMigrationManager(sourceModel: sourceModel!, destinationModel: destinationModel!)
            
            migrationManager.addObserver(self,
                                         forKeyPath: "migrationProgress",
                                         options: .new,
                                         context: nil)
            try migrationManager.migrateStore(from: sourceStoreURL,
                                                     sourceType: type,
                                                     options: nil,
                                                     with: mappingModel,
                                                     toDestinationURL: destStoreURL,
                                                     destinationType: type,
                                                     destinationOptions: nil)
            migrationManager.removeObserver(self, forKeyPath: "migrationProgress")
            
            
            if (!self.BackupSourceStoreAtURL(sourceStoreURL, dstStoreURL: destStoreURL)) {
                return false
            }
            
            return !self.IsMigrationNeeded()
        } catch {
            NSLog("ProgressivelyMigrate Error: \(error)")
            return false
        }
    }
    
    func IsMigrationNeeded() -> Bool {
        let srcStoreUrl = DOCUMENTS_URL().appendingPathComponent(self.p_dataBaseName!).appendingPathExtension("sqlite")
        
        do {
            let srcMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: srcStoreUrl)
            if (self.p_dbModel != nil) {
                return !self.p_dbModel!.isConfiguration(withName: nil, compatibleWithStoreMetadata: srcMetadata)
            }
        } catch {
            NSLog("\(error)")
        }
        return false
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "migrationProgress" {
            NSLog("Migration process: %.2f%%", (object as! NSMigrationManager).migrationProgress * 100.0)
        } else {
            super.observeValue(forKeyPath: keyPath, of:object, change:change, context:context)
        }
    }
}
