//
//  Post.swift
//  IdealVisual
//
//  Created by a.kurganova on 29.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import CoreData
import Foundation
import UIKit

class CoreDataPost {
    static func createPost(photoURL: URL, date: Date, place: String, text: String) {
        let entityDescriptionPost = NSEntityDescription.entity(forEntityName: "Post",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectPost = NSManagedObject(entity: entityDescriptionPost!,
                                                insertInto: DataManager.instance.managedObjectContext)

        managedObjectPost.setValue(photoURL, forKey: "photo")
        managedObjectPost.setValue(date, forKey: "date")
        managedObjectPost.setValue(place, forKey: "place")
        managedObjectPost.setValue(text, forKey: "text")

        DataManager.instance.saveContext()
    }

    static func getPosts() -> NSSet? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        do {
            let posts = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            print("postsData: \(NSSet(array: posts))")
            return NSSet(array: posts)
        } catch {
            print(error)
        }
        return nil
    }

    static func getPost() -> Post? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        do {
            let posts = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            for post0 in (posts as? [Post])! {
                print("""
                    postData:   \(String(describing: post0.photo)),
                                \(String(describing: post0.date)),
                                \(post0.place ?? "no place")
                                \(post0.text ?? "no text")
                    """)
            }
            return posts.last as? Post
        } catch {
            print(error)
        }
        return nil
    }
}
