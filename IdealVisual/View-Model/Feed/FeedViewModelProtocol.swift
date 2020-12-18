//
//  FeedViewModelProtocol.swift
//  IdealVisual
//
//  Created by Alexandra Kurganova on 29.11.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

protocol FeedViewModelProtocol {
    var posts: [Post] { get }
    func create(photoName: String, photoData: Data?, date: Date?, place: String?, text: String?,
                completion: ((PostViewModelErrors?) -> Void)?)
    func delete(atIndices: [Int], completion: ((PostViewModelErrors?) -> Void)?)
}
