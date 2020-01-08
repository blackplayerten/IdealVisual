//
//  User.swift
//  IdealVisual
//
//  Created by a.kurganova on 02.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UserCoreData: UserCoreDataProtocol {
    private var cacheUser: User?

    func create(token: String, username: String, email: String, ava: String? = "") -> User? {
        let entityDescriptionUser = NSEntityDescription.entity(forEntityName: "User",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectUser = NSManagedObject(entity: entityDescriptionUser!,
                                                insertInto: DataManager.instance.managedObjectContext)

        managedObjectUser.setValue(token, forKey: "token")
        managedObjectUser.setValue(username, forKey: "username")
        managedObjectUser.setValue(email, forKey: "email")
        managedObjectUser.setValue(ava ?? "", forKey: "ava")

        cacheUser = managedObjectUser.managedObjectContext?.registeredObjects.first as? User

        DataManager.instance.saveContext()
        return cacheUser
    }

    func update(username: String?, email: String?, avatar: String?) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let users = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            cacheUser = users.last as? User
            if let username = username {
                if username != "" {
                    cacheUser?.setValue(username, forKey: "username")
                }
            }
            if let email = email {
                if email != "" {
                    cacheUser?.setValue(email, forKey: "email")
                }
            }
            if let avatar = avatar {
                if avatar != "" {
                    cacheUser?.setValue(avatar, forKey: "ava")
                }
            }
            DataManager.instance.saveContext()
        } catch {
            Logger.log(error)
        }
    }

    func get() -> User? {
        if cacheUser != nil {
            return cacheUser
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let users = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            cacheUser = users.last as? User
            return cacheUser
        } catch {
            Logger.log(error)
        }
        return nil
    }

    private func cleanCache() {
        cacheUser = nil
    }

    func delete() {
        guard let cacheUser = cacheUser else { return }
        DataManager.instance.managedObjectContext.delete(cacheUser)
        DataManager.instance.saveContext()

        cleanCache()
    }
}
