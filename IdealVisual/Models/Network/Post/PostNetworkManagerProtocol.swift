//
//  PostNetworkManagerProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

protocol PostNetworkManagerProtocol {
    func create(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?)
    func get(token: String, completion: (([JsonPostModel]?, NetworkError?) -> Void)?)
    func update(token: String, post: JsonPostModel, completion: ((JsonPostModel?, NetworkError?) -> Void)?)
    func delete(token: String, ids: [UUID], completion: ((NetworkError?) -> Void)?)
}
