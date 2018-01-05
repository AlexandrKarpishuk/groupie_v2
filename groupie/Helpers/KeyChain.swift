//
//  KeyChain.swift
//  Groupie
//
//  Created by Sania on 28.07.17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class KeyChain {
    
    class func GetPassword(_ service: String, account: String) -> String? {
        
        let queryParams = NSMutableDictionary()
        queryParams[NSString(format:kSecClass)] = kSecClassGenericPassword
        queryParams[NSString(format:kSecAttrService)] = service
        queryParams[NSString(format:kSecAttrAccount)] = account
 //       queryParams[NSString(format:kSecMatchLimit)] = kSecMatchLimitOne
 //       queryParams[NSString(format:kSecReturnPersistentRef)] = kCFBooleanTrue
        queryParams[NSString(format:kSecReturnData)] = kCFBooleanTrue
 //       queryParams[NSString(format:kSecReturnAttributes)] = kCFBooleanTrue
 //       queryParams[NSString(format:kSecAttrAccessible)] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

        var result : AnyObject?
        let status = SecItemCopyMatching(queryParams, &result)
        
        if (status == errSecSuccess) {
            if result is NSData && result != nil {
                return String(data: result as! Data, encoding: .utf8)
            }
        }
        
        NSLog("Can't found data for \(service) : \(account)")
        return nil
    }
    
    
    class func SetPassword(_ service: String, account: String, password: String) {
        let queryParams = NSMutableDictionary()
        queryParams[NSString(format:kSecClass)] = kSecClassGenericPassword
        queryParams[NSString(format:kSecAttrService)] = service
        queryParams[NSString(format:kSecAttrAccount)] = account
 //       queryParams[NSString(format:kSecAttrAccessible)] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
 //       queryParams[NSString(format:kSecMatchLimit)] = kSecMatchLimitAll
        

        let toUpdate = NSMutableDictionary()
        toUpdate[NSString(format:kSecValueData)] = password.data(using: .utf8)
        var status = SecItemUpdate(queryParams, toUpdate)
        if (status != errSecSuccess) {
            queryParams[NSString(format:kSecValueData)] = password.data(using: .utf8)
            
            var result: AnyObject?
            status = SecItemAdd(queryParams, &result)
            if (status == errSecSuccess) {
                NSLog("Item append Success: \(service) \(account)")
            }
        } else {
            NSLog("Item updated Success: \(service) \(account)")
        }
    }
    
    class func RemovePassword(_ service: String, account: String) {
        
        let queryParams = NSMutableDictionary()
        queryParams[NSString(format:kSecClass)] = kSecClassGenericPassword
        queryParams[NSString(format:kSecAttrService)] = service
        queryParams[NSString(format:kSecAttrAccount)] = account
   //     queryParams[NSString(format:kSecMatchLimit)] = NSString(format: kSecMatchLimitOne)
  //      queryParams[NSString(format:kSecAttrAccessible)] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
 //       queryParams[NSString(format:kSecReturnPersistentRef)] = kCFBooleanTrue
        
        let status = SecItemDelete(queryParams)
        
        if (status == errSecSuccess) {
            NSLog("Item removed Success: \(service) \(account)")
        } else {
            NSLog("Fail while remove item: \(service) \(account)\n Fail: \(status)")
        }
    }
}
