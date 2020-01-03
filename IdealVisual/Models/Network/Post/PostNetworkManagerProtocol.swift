//
//  PostNetworkManagerProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

protocol PostNetworkManagerProtocol {
    func create(post: JsonPostModel, completion: ((NetworkError?) -> Void)?)
    func get(completion: (([JsonPostModel]?, NetworkError?) -> Void)?)
    func update(post: JsonPostModel, completion: ((NetworkError?) -> Void)?)
    func delete(ids: [UUID], completion: ((NetworkError?) -> Void)?)
}
