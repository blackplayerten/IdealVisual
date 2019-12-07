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
    static private var post: Post?

    static func createPost(photo: String, date: Date, place: String, text: String, orderNum: Int) -> Post? {
        let entityDescriptionPost = NSEntityDescription.entity(forEntityName: "Post",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectPost = NSManagedObject(entity: entityDescriptionPost!,
                                                insertInto: DataManager.instance.managedObjectContext)

        managedObjectPost.setValue(photo, forKey: "photo")
        managedObjectPost.setValue(date, forKey: "date")
        managedObjectPost.setValue(place, forKey: "place")
        managedObjectPost.setValue(text, forKey: "text")
        managedObjectPost.setValue(Int64(orderNum), forKey: "orderNum")

        DataManager.instance.saveContext()

        post = managedObjectPost as? Post
        print("create")
        return post
    }

    static func updatePost(post: Post, date: Date? = nil, place: String? = nil, text: String? = nil) {
        do {
            if let date = date {
                post.setValue(date, forKey: "date")
            }
            if let place = place {
                post.setValue(place, forKey: "place")
            }
            if let text = text {
                post.setValue(text, forKey: "text")
            }
            try DataManager.instance.managedObjectContext.save()
            DataManager.instance.saveContext()
            print(post)
        } catch {
            print(error)
        }
    }

    static func getPosts() -> [Post]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        do {
            let posts = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            return posts as? [Post]
        } catch {
            print(error)
        }
        return nil
    }

    static func getPost() -> Post? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        do {
            let posts = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            post = posts.last as? Post
            return post
        } catch {
            print(error)
        }
        return nil
    }

    static func deletePost(post: Post) {
        DataManager.instance.managedObjectContext.delete(post)
        DataManager.instance.saveContext()
    }
}
