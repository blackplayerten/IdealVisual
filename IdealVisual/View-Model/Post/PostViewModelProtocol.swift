//
//  PhotoViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 27.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import PromiseKit

protocol PostViewModelProtocol {
    var posts: [Post] { get }
    func create(photoName: String, photoData: Data?, date: Date?, place: String?,
                text: String?) -> Promise<Void>
    func getPhoto(path: String) -> String
    func update(post: Post, date: Date?, place: String?, text: String?) -> Promise<Void>
    func subscribe(completion: @escaping (PostViewModelProtocol) -> Void)
    func delete(atIndices: [Int]) -> Promise<Void>
    func swap(source: Int, dest: Int) throws
    func sync() -> Promise<Void>
}
