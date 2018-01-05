//
//  DBCreateObjectsOperation.swift
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


class DBCreateObjectsOperation : DBBaseOperation {
    
    var classDescription: NSEntityDescription?
    var objectInfoArray: NSArray?
    var finishedWithArray: ((NSArray)->Void)?
    
    override func main() {

        let result = NSMutableArray()
        
        if (self.objectInfoArray != nil) {
            for objectInfo in self.objectInfoArray! {
                if let info = objectInfo as? NSDictionary {
                    if (self.isCancelled == true) {
                        return
                    }
                    var resultObject : NSManagedObject?
                    if (info["id"] == nil || self.classDescription == nil) {
                        resultObject = CreateNewObject()
                    } else {
                        var objectsInCoreData : [AnyObject]?
                        switch (info["id"]) {
                        case is NSNumber:
                            objectsInCoreData = self.GetObjectsWithID(Int64((info["id"] as! NSNumber).intValue))
                            break
                        case is String:
                            objectsInCoreData = self.GetObjectsWithID(Int64(info["id"] as! String)!)
                            break
                        case is NSString:
                            objectsInCoreData = self.GetObjectsWithID(Int64(info["id"] as! String)!)
                            break
                        default:
                            break
                        }
                        
                        if (self.isCancelled == true) {
                            return
                        }
                        if (objectsInCoreData?.count > 0) {
                            resultObject = objectsInCoreData!.first as? NSManagedObject
                            
                            if (self.isCancelled == true) {
                                return
                            }
                            objectsInCoreData!.removeFirst()
                            for object in objectsInCoreData! {
                                let tmpObject = object as! NSManagedObject
                                self.dbContext!.delete(tmpObject)
                            }
                        } else {
                            resultObject = self.CreateNewObject()
                        }
                    }

                    if (self.isCancelled == true) {
                        return
                    }
                    resultObject!.initWithInfo(info)
                    result.add(resultObject!)
                }
            }
        }
        
        if (self.isCancelled == true) {
            return
        }
        if (self.finishedWithArray != nil) {
            self.finishedWithArray!(result)
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
    }
    
    fileprivate func ClassName(_ dstClass:String) -> String {
        let range = dstClass.range(of: ".")
        if range?.upperBound != range?.lowerBound {
            return dstClass.substring(from: range!.upperBound)
        }
        return dstClass
    }
    
    func CreateNewObject() -> NSManagedObject? {
        return NSEntityDescription.insertNewObject(forEntityName: self.ClassName(self.classDescription!.managedObjectClassName), into: self.dbContext!)
    }
    
    func GetObjectsWithID(_ id:Int64) -> [AnyObject]? {
        let fetchRequest:NSFetchRequest<NSManagedObject> = NSFetchRequest<NSManagedObject>()
        fetchRequest.entity = self.classDescription
        
        let filter = "id==\(id)"
        let predicate = NSPredicate(format:filter, argumentArray: nil)
        fetchRequest.predicate = predicate
        
        if (self.isCancelled == true) {
            return nil
        }
        
        var resultObjects : [AnyObject]?
        do {
            resultObjects = try self.dbContext!.fetch(fetchRequest)
        } catch {
            return nil
        }
        
        if (self.isCancelled == true) {
            return nil
        }
        
        return resultObjects
    }
    
}
