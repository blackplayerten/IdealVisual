//
//  Feed.swift
//  IdealVisual
//
//  Created by a.kurganova on 25.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class CoreDataFeed {
    static func setFeed() {
        let entityDescriptionFeed = NSEntityDescription.entity(forEntityName: "Feed",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectFeed = NSManagedObject(entity: entityDescriptionFeed!,
                                                insertInto: DataManager.instance.managedObjectContext)
        managedObjectFeed.setValue(CoreDataUser.getUser(), forKey: "user")
        managedObjectFeed.setValue(CoreDataPost.getPosts(), forKey: "post")
        DataManager.instance.saveContext()
    }
}
