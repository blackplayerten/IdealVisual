//
//  PhotoNetworkProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

protocol PhotoNetworkManagerProtocol {
    func get(path: String) -> Promise<Data>
    func upload(token: String, data: Data, name: String) -> Promise<String>
}
