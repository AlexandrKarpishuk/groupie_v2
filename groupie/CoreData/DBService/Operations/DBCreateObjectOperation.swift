//
//  DBCreateObjectOperation.swift
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


class DBCreateObjectOperation : DBBaseOperation {
    
    var classDescription: NSEntityDescription?
    var objectInfo: NSDictionary?
    var finishedWithObject: ((NSManagedObject)->Void)?
    
    override func main() {
        
        if (self.isCancelled == true) {
            return
        }
        var result : NSManagedObject?
        if (self.objectInfo?["id"] == nil || self.classDescription == nil) {
            result = CreateNewObject()
        } else {
            var objectsInCoreData : [AnyObject]?
            switch (self.objectInfo!["id"]) {
            case is NSNumber:
                objectsInCoreData = self.GetObjectsWithID(Int64((self.objectInfo!["id"] as! NSNumber).intValue))
                break
            case is String:
                objectsInCoreData = self.GetObjectsWithID(Int64(self.objectInfo!["id"] as! String)!)
                break
            case is NSString:
                objectsInCoreData = self.GetObjectsWithID(Int64(self.objectInfo!["id"] as! String)!)
                break
            default:
                break
            }
            
            if (self.isCancelled == true) {
                return
            }
            if (objectsInCoreData?.count > 0) {
                result = objectsInCoreData!.first as? NSManagedObject
                
                if (self.isCancelled == true) {
                    return
                }
                objectsInCoreData!.removeFirst()
                for object in objectsInCoreData! {
                    let tmpObject = object as! NSManagedObject
                    self.dbContext!.delete(tmpObject)
                }
            } else {
                result = self.CreateNewObject()
            }
        }
        
        if (self.objectInfo != nil) {
            if (self.isCancelled == true) {
                return
            }
            result!.initWithInfo(self.objectInfo as! [AnyHashable: Any] as NSDictionary)
        }
        
        if (self.isCancelled == true) {
            return
        }
        if (self.finishedWithObject != nil) {
            self.finishedWithObject!(result!)
        }
        if (self.operationDidFinish != nil) {
            self.operationDidFinish!(nil)
        }
    }
    
    fileprivate func ClassName(_ dstClass:String) -> String {
        let range = dstClass.range(of: ".")
        if range?.lowerBound != range?.upperBound {
            return dstClass.substring(from: range!.upperBound)
        }
        return dstClass
    }
    
    fileprivate func CreateNewObject() -> NSManagedObject? {
        return NSEntityDescription.insertNewObject(forEntityName: self.ClassName(self.classDescription!.managedObjectClassName), into: self.dbContext!)
    }

    fileprivate func GetObjectsWithID(_ id:Int64) -> [AnyObject]? {
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
