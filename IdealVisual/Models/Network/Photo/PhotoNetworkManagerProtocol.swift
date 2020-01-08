//
//  PhotoNetworkProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

protocol PhotoNetworkManagerProtocol {
    func get(path: String, completion: ((Data?, NetworkError?) -> Void)?)
    func upload(token: String, data: Data, name: String, completion: ((String?, NetworkError?) -> Void)?)
}
