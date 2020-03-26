//
//  PostNetworkManagerProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 01.01.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import PromiseKit

protocol PostNetworkManagerProtocol {
    func create(token: String, post: JsonPostModel) -> Promise<JsonPostModel>
    func get(token: String) -> Promise<[JsonPostModel]>
    func update(token: String, post: JsonPostModel) -> Promise<JsonPostModel>
    func delete(token: String, ids: [UUID]) -> Promise<NetworkErr>
}
