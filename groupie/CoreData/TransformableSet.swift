//
//  TransformableSet.swift
//  Sigma
//
//  Created by Sania on 12.09.16.
//  Copyright © 2016 Fructose Tech. All rights reserved.
//

import Foundation

public class TransformableSet : ValueTransformer {
    
    override public class func transformedValueClass() -> AnyClass {
        return NSSet.self
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        return NSKeyedArchiver.archivedData(withRootObject: value!)
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with:value as! Data)
    }
    
    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
    
}

extension NSValueTransformerName {
    static let classNameTransformerName = NSValueTransformerName(rawValue: "TransformableSet")
}


