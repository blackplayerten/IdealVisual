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

    static func createPost(photo: String, date: Date, place: String, text: String, indexPhoto: Int) -> Post? {
        let entityDescriptionPost = NSEntityDescription.entity(forEntityName: "Post",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectPost = NSManagedObject(entity: entityDescriptionPost!,
                                                insertInto: DataManager.instance.managedObjectContext)

        managedObjectPost.setValue(photo, forKey: "photo")
        managedObjectPost.setValue(date, forKey: "date")
        managedObjectPost.setValue(place, forKey: "place")
        managedObjectPost.setValue(text, forKey: "text")
        managedObjectPost.setValue(Int64(indexPhoto), forKey: "indexPhoto")

        DataManager.instance.saveContext()

        post = managedObjectPost as? Post
        print("create post, index: \(indexPhoto)")
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
            print(post)
        } catch {
            print(error)
        }
    }

    // swiftlint:disable line_length
    static func getPosts() -> NSFetchedResultsController<Post> {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "indexPhoto", ascending: true)
        fetchRequest.sortDescriptors = [sortDesc]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                               managedObjectContext: DataManager.instance.managedObjectContext,
                                                               sectionNameKeyPath: nil, cacheName: nil
        )
        return fetchResultController
    }
    // swiftlint:enable line_length

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

    static func swapPosts(_ posts: [Post], source: Int, dest: Int) {
        var posts = posts
        let draggedPost = posts.remove(at: source)
        posts.insert(draggedPost, at: dest)

        // better to reinit all indices than reinit indices for elements after new drop position,
        // because they can be broken
        for (index, post) in posts.enumerated() {
            post.indexPhoto = Int64(index)
        }

        DataManager.instance.saveContext()
    }
}
