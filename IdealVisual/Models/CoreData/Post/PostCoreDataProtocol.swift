//
//  PostProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 27.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import CoreData
import Foundation

protocol PostCoreDataProtocol: class {
    func create(user: User, id: UUID?, photo: String, date: Date, place: String,
                text: String, indexPhoto: Int, lastUpdated: Date?) -> Post?
    func update(post: Post, id: UUID?, date: Date?, place: String?, text: String?, indexPhoto: Int?,
                lastUpdated: Date?) throws
    func getAll() -> NSFetchedResultsController<Post>
    func get() -> Post?
    func delete(post: Post) throws
    func reinitIndices(posts: [Post])
    func swap(_ posts: [Post], source: Int, dest: Int)
}
