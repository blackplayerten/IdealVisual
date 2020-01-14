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

final class PostCoreData: PostCoreDataProtocol {
    func create(user: User, id: UUID? = nil,
                photo: String, date: Date, place: String, text: String, indexPhoto: Int,
                lastUpdated: Date? = Date()) -> Post? {
        let entityDescriptionPost = NSEntityDescription.entity(forEntityName: "Post",
                                                               in: DataManager.instance.managedObjectContext)
        let managedObjectPost = NSManagedObject(entity: entityDescriptionPost!,
                                                insertInto: DataManager.instance.managedObjectContext)

        if let id = id {
            managedObjectPost.setValue(id, forKey: "id")
        } else {
            managedObjectPost.setValue(UUID(uuid: UUID_NULL), forKey: "id")
        }
        managedObjectPost.setValue(photo, forKey: "photo")
        managedObjectPost.setValue(date, forKey: "date")
        managedObjectPost.setValue(place, forKey: "place")
        managedObjectPost.setValue(text, forKey: "text")
        managedObjectPost.setValue(Int64(indexPhoto), forKey: "indexPhoto")
        if let lastUpdated = lastUpdated {
            managedObjectPost.setValue(lastUpdated, forKey: "lastUpdated")
        } else {
            managedObjectPost.setValue(Date(), forKey: "lastUpdated")
        }

        guard let post = managedObjectPost as? Post else { return nil }
        user.addToPosts(post)

        DataManager.instance.saveContext()
        return post
    }

    func update(post: Post, id: UUID? = nil, date: Date? = nil, place: String? = nil, text: String? = nil,
                indexPhoto: Int? = nil, lastUpdated: Date? = nil) {
        do {
            if let id = id {
                post.setValue(id, forKey: "id")
            }
            if let date = date {
                post.setValue(date, forKey: "date")
            }
            if let place = place {
                post.setValue(place, forKey: "place")
            }
            if let text = text {
                post.setValue(text, forKey: "text")
            }
            if let indexPhoto = indexPhoto {
                post.setValue(Int64(indexPhoto), forKey: "indexPhoto")
            }
            if let lastUpdated = lastUpdated {
                post.setValue(lastUpdated, forKey: "lastUpdated")
            }
            try DataManager.instance.managedObjectContext.save()
        } catch {
            Logger.log(error)
        }
    }

    func getAll() -> NSFetchedResultsController<Post> {
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        let sortDesc = NSSortDescriptor(key: "indexPhoto", ascending: true)
        fetchRequest.sortDescriptors = [sortDesc]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                    managedObjectContext: DataManager.instance.managedObjectContext,
                                    sectionNameKeyPath: nil, cacheName: nil
        )
        return fetchResultController
    }

    func get() -> Post? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        do {
            let posts = try DataManager.instance.managedObjectContext.fetch(fetchRequest)
            let post = posts.last as? Post
            return post
        } catch {
            Logger.log(error)
        }
        return nil
    }

    func delete(post: Post) {
        DataManager.instance.managedObjectContext.delete(post)
        DataManager.instance.saveContext()
    }

    func reinitIndices(posts: [Post]) {
        for (index, post) in posts.enumerated() {
            post.indexPhoto = Int64(index)
        }

        DataManager.instance.saveContext()
    }

    func swap(_ posts: [Post], source: Int, dest: Int) {
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
