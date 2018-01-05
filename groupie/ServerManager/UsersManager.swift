//
//  UsersManager.swift
//  groupie
//
//  Created by Sania on 11/10/17.
//  Copyright © 2017 DaisyDaisy. All rights reserved.
//

import Foundation

class UsersManager {
    
    static var shared = UsersManager()
    
    fileprivate var p_cache = [String: UserInfo]()

    func getUser(userName: String?, completed:((UserInfo)->Void)?, fail:(()->Void)? = nil) {
        if (userName != nil) {
            if (self.p_cache[userName!] != nil) {
                let cachedUser = self.p_cache[userName!]!
                completed?(cachedUser)
                if (cachedUser.lastUpdate == nil || Date().timeIntervalSince(cachedUser.lastUpdate!) > 5 * 60) {
                    self.readUserFromServer(userName: userName!, completed: nil, fail: fail)
                }
            } else {
                self.readUserFromDataBase(userName: userName!, completed: completed, fail: fail)
            }
        } else {
            fail?()
        }
    }
    
    fileprivate func readUserFromDataBase(userName: String, completed:((UserInfo)->Void)?, fail:(()->Void)?) {
        DBService.shared.AllObjectsOfClass(UserEntity.self, filter: "username='\(userName)'") { (result:NSArray?) in
            if (result != nil && result!.count > 0) {
                let entity = result!.firstObject as! UserEntity
                let info = UserInfo(info: nil)
                info.fromEntity(entity)
                self.p_cache[userName] = info
                DispatchQueue.main.async {
                    completed?(info)
                }
            } else {
                self.readUserFromServer(userName: userName, completed: completed, fail: fail)
            }
        }
    }
    
    fileprivate func readUserFromServer(userName: String, completed:((UserInfo)->Void)?, fail:(()->Void)?) {
        ServerManager.shared.GetUserInfo(userNick: userName, onSuccess: { (user:UserInfo) in
            user.lastUpdate = Date()
            self.p_cache[userName] = user
            DispatchQueue.main.async {
                completed?(user)
            }
            DBService.shared.AllObjectsOfClass(UserEntity.self, filter: "username='\(userName)'", completed: { (result: NSArray?) in
                if (result != nil) {
                    DBService.shared.RemoveObjects(result!)
                }
                if let entity = DBService.shared.CreateObjectFromCurrentThread(UserEntity.self) as? UserEntity {
                    user.toEntity(entity)
                }
            })
        }) { (_:String?) in
            fail?()
        }
    }
}
