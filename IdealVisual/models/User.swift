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

class CoreDataUser {
    static func createUser(username: String, email: String) {
        let entityDescriptionUser = NSEntityDescription.entity(forEntityName: "User",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectUser = NSManagedObject(entity: entityDescriptionUser!,
                                                insertInto: DataManager.instance.managedObjectContext)

        managedObjectUser.setValue("\(username)", forKey: "username")
        managedObjectUser.setValue("\(email)", forKey: "email")
        managedObjectUser.setValue("\(String(describing: UIImage(named: "default_profile")))", forKey: "ava")

        DataManager.instance.saveContext()
    }

    static func updateAvatar(image: UIImage) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let users = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            let usersO = users as? [User]
            let nowUser = usersO?.last
            nowUser?.setValue("\(String(describing: image))", forKey: "ava")
            DataManager.instance.saveContext()
        } catch {
            print(error)
        }
    }

    static func getUser() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let users = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            for user in (users as? [User])! {
                print("""
                        userData: \(user.username ?? "no userneme"),
                                    \(user.email ?? "no email"),
                                    \(user.ava ?? "no ava" as NSObject)
                    """)
            }
        } catch {
            print(error)
        }
    }

}
