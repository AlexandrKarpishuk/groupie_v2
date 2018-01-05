//
//  Reflection.swift
//
//  Created by Sania on 08.09.16.
//  Copyright © 2016 Sania. All rights reserved.
//

import Foundation
import CoreData

#if DEBUG
    private let TEST_NEW_PROPERTIES = true
#else
    private let TEST_NEW_PROPERTIES = false
#endif

class ReflectionObject {
    
    func serialize() -> [String: Any] {
        return privateSerialize(self)
    }
    
}

//NSManagedObject Reflection
extension NSManagedObject {
    
    func serialize() -> [String:Any] {
        return privateSerialize(self)
    }
    
    func initWithInfo(_ info:NSDictionary) {
        var infoAllKeys = NSMutableArray()
        if (TEST_NEW_PROPERTIES) {
            infoAllKeys = NSMutableArray(array: (info as NSDictionary).allKeys)
        }

        let attributes = self.entity.attributesByName
        for (attrName, attrDesc) in attributes {
            if (TEST_NEW_PROPERTIES) {
                infoAllKeys.remove(attrName)
            }
            if let value = info[attrName] {
                var isNull = false
                if (value is NSNull) {
                    isNull = true
                }
                if (value is String || value is NSString) {
                    if (value as! String == "<null>") {
                        isNull = true
                    }
                }
                
                if (!self.customConvert(value as AnyObject?, forKey: attrName)) {
                    if (!isNull) {
                        if (attrDesc.attributeType == NSAttributeType.stringAttributeType) {
                            self.setValue(String(describing: value), forKey: attrName)
                        } else {
                            self.setValue(value, forKey: attrName)
                        }
                    }
                }
            } else if (attrName == "desc") {
                if (TEST_NEW_PROPERTIES) {
                    infoAllKeys.remove("description")
                }
                if let value = info["description"] {
                    if (attrDesc.attributeType == NSAttributeType.stringAttributeType) {
                        self.setValue(String(describing: value), forKey: attrName)
                    } else {
                        self.setValue(value, forKey: attrName)
                    }
                }
            } else if (attrName == "isPublic") {
                if (TEST_NEW_PROPERTIES) {
                    infoAllKeys.remove("public")
                }
                if let value = info["public"] {
                    if (attrDesc.attributeType == NSAttributeType.stringAttributeType) {
                        self.setValue(String(describing: value), forKey: attrName)
                    } else {
                        self.setValue(value, forKey: attrName)
                    }
                }
            }
        }
  /* // Duplicate with attributes
        let properties = self.entity.propertiesByName
        for (propertyName, _) in properties {
            if (TEST_NEW_PROPERTIES) {
                infoAllKeys.removeObject(propertyName)
            }
            if let value = info[propertyName] {
                if (!self.customConvert(value, forKey: propertyName)) {
                    self.setValue(value, forKey: propertyName)
                }
            } else if (propertyName == "desc") {
                if (TEST_NEW_PROPERTIES) {
                    infoAllKeys.removeObject("description")
                }
                if let value = info["description"] {
                    if (!self.customConvert(value, forKey: propertyName)) {
                        self.setValue(value, forKey: propertyName)
                    }
                }
            }
        }
        */
        let relationships = self.entity.relationshipsByName
        for (relationName, relationshipDesc) in relationships {
            if (TEST_NEW_PROPERTIES) {
                infoAllKeys.remove(relationName)
            }
            if let value = info[relationName] {
                if (!self.customConvert(value as AnyObject?, forKey: relationName)) {
                    let valClass = NSClassFromString(relationshipDesc.destinationEntity!.managedObjectClassName) as! NSObject.Type
                    if (relationshipDesc.isToMany) {
                        if let savedSet = self.value(forKey: relationName) as? NSSet {

                            let savedSetObjects = savedSet.allObjects
                            let resultSet = NSMutableSet()
                            var needRemoveOldValues = true
                            var index = 0
                            for objectInfo in (value as? NSArray)! {
                                if (objectInfo as? NSDictionary)!["id"] != nil {
                                    needRemoveOldValues = false
                                    let filter = "id==\((objectInfo as? NSDictionary)!["id"]!)"
                                    let saved = DBService.shared.AllObjectsFromCurrentThread(valClass, filter:filter)
                                    if (saved.count > 0) {
                                        let objectWithSameID = saved.firstObject as! NSManagedObject
                                        objectWithSameID.initWithInfo(objectInfo as! NSDictionary)
                                        resultSet.add(objectWithSameID)
                                    } else {
                                        let newObject = DBService.shared.CreateObjectFromCurrentThread(valClass, info: objectInfo as? NSDictionary)
                                        resultSet.add(newObject)
                                    }
                                } else {
                                    if (index < savedSetObjects.count) {
                                        let savedObject = savedSetObjects[index] as! NSManagedObject
                                        savedObject.initWithInfo(objectInfo as! NSDictionary)
                                        resultSet.add(savedObject)
                                    } else {
                                        let newObject = DBService.shared.CreateObjectFromCurrentThread(valClass, info: objectInfo as? NSDictionary)
                                        resultSet.add(newObject)
                                    }
                                }
                                index += 1
                            }
                            self.setValue(resultSet, forKey: relationName)
                            if (needRemoveOldValues) {
                                for savedObject in savedSet {
                                    if (!resultSet.contains(savedObject)) {
                                        DBService.shared.RemoveObjectFromCurrentThread(savedObject as? NSManagedObject)
                                    }
                                }
                            }
                        } else {
                            let objects = DBService.shared.CreateObjectsFromCurrentThread(valClass, infoArray:(info[relationName] as? NSArray)!)
                            self.setValue(objects, forKey: relationName)
                        }
                    } else {
                        if let savedObject = self.value(forKey: relationName) as? NSManagedObject {
                            if (value as? NSDictionary)!["id"] != nil {
                                let filter = "id==\((value as? NSDictionary)!["id"]!)"
                                let saved = DBService.shared.AllObjectsFromCurrentThread(type(of: savedObject), filter:filter)
                                if (saved.count > 0) {
                                    let objectWithSameID = saved.firstObject as! NSManagedObject
                                    objectWithSameID.initWithInfo(value as! NSDictionary)
                                    self.setValue(objectWithSameID, forKey: relationName)
                                } else {
                                    let newObject = DBService.shared.CreateObjectFromCurrentThread(valClass, info:value as? NSDictionary)
                                    self.setValue(newObject, forKey: relationName)
                                }
                            } else {
                                savedObject.initWithInfo(value as! NSDictionary)
                            }
                        } else {
                            let newObject = DBService.shared.CreateObjectFromCurrentThread(valClass, info:value as? NSDictionary)
                            self.setValue(newObject, forKey: relationName)
                        }
                    }
                }
            }
        }
        
        if (TEST_NEW_PROPERTIES && infoAllKeys.count > 0) {
            NSLog("[\(type(of: self))] Can't find: \(infoAllKeys)")
        }
    }
    
  /*  private func ClassName(dstClass:String) -> String {
        let range = dstClass.rangeOfString(".")
        if range?.count != 0 {
            return dstClass.substringFromIndex(range!.endIndex)
        }
        return dstClass
    }*/
    
    func customConvert(_ value:AnyObject?, forKey:String) -> Bool {
        return false
    }
}

//MARK: - Private Serialize
private func privateSerialize(_ object:Any) -> [String: Any] {
    var result = [String: Any!]()
    
    var ref : Mirror? = Mirror(reflecting:object)
    repeat {
        for child in ref!.children {
            if !(child.value is ExpressibleByNilLiteral)  {
                if child.value is ReflectionObject {
                    result[child.label!] = (child.value as! ReflectionObject).serialize()
                } else {
                    switch (Mirror(reflecting:child.value).displayStyle) {
                        
                    case .collection?:
                        result[child.label!] = serializeArray(child.value)
                        break
                        
                    case .set?:
                        result[child.label!] = serializeArray((child.value as! NSSet).allObjects)
                        break
                        
                    case .dictionary?:
                        result[child.label!] = serializeDictionary(child.value)
                        break
                        
                    default:
                        result[child.label!] = child.value
                        break
                    }
                }
            }
        }
        ref = ref!.superclassMirror
    } while (ref != nil)
    return result
}

private func serializeArray(_ array:Any) -> [Any]! {
    
    var result: [Any] = [Any]()
    
    let mirr = Mirror(reflecting: array)
    for child in mirr.children {
        if case let val as Any? = child.value { // Convert to optional
            if (val != nil) {
                if child.value is ReflectionObject {
                    result.append((child.value as! ReflectionObject).serialize())
                } else {
                    switch (Mirror(reflecting:child.value).displayStyle) {
                        
                    case .collection?:
                        result.append(serializeArray(child.value))
                        break
                        
                    case .set?:
                        result.append(serializeArray((child.value as! NSSet).allObjects))
                        break
                        
                    case .dictionary?:
                        result.append(serializeDictionary(child.value))
                        break
                        
                    default:
                        result.append(val!)
                        break
                    }
                }
            }
        }
        
    }
    
    return result
}


private func serializeDictionary(_ dict:Any) -> [String: Any]! {
    var result: [String: Any] = [:]
    
    let mirr = Mirror(reflecting: dict)
    for child in mirr.children {
        if (child.label != nil) {
            if case let val as Any? = child.value { // Convert to optional
                if (val != nil) {
                    let dictMirror = Mirror(reflecting: child.value)
                    
                    var key : Any?
                    var val : Any?
                    var index = 0
                    for dictChild in dictMirror.children {
                        NSLog("\(dictChild.label!) = \(dictChild.value)")
                        switch (index) {
                        case 0:
                            if case let optVal as Any? = dictChild.value { // Convert to optional
                                if (optVal != nil) {
                                    key = optVal
                                }
                            }
                            break
                        case 1:
                            if case let optVal as Any? = dictChild.value { // Convert to optional
                                if (optVal != nil) {
                                    val = optVal
                                }
                            }
                            break
                        default:
                            break
                        }
                        index += 1
                    }
                    if (key != nil && val != nil) {
                        if val is ReflectionObject {
                            result[key! as! String] = (val! as! ReflectionObject).serialize()
                        } else {
                            switch (Mirror(reflecting:val).displayStyle) {
                            case .collection?:
                                result[key! as! String] = serializeArray(val!)
                                break
                            case .set?:
                                result[key! as! String] = serializeArray((val! as! NSSet).allObjects)
                                break
                            case .dictionary?:
                                result[key! as! String] = serializeDictionary(val!)
                                break
                                
                            default:
                                result[key! as! String] = val
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    return result
}
