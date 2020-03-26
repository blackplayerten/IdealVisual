//
//  UserNetworkManagerProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

protocol UserNetworkManagerProtocol {
    func create(newUser: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?)
    func login(user: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?)
    func update(token: String, user: JsonUserModel, completion: ((JsonUserModel?, NetworkErr?) -> Void)?)
    func logout(token: String, completion: ((NetworkErr?) -> Void)?)
}
