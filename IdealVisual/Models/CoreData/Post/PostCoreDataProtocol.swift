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
    func create(photo: String, date: Date, place: String, text: String, indexPhoto: Int) -> Post?
    func update(post: Post, date: Date?, place: String?, text: String?)
    func getAll() -> NSFetchedResultsController<Post>
    func get() -> Post?
    func delete(post: Post)
    func swap(_ posts: [Post], source: Int, dest: Int)
}
