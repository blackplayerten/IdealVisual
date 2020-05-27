//
//  UserViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

protocol UserViewModelProtocol {
    var user: User? { get }
    func create(username: String, email: String, password: String, completion: ((UserViewModelErrors?) -> Void)?)
    func login(email: String, password: String, completion: ((UserViewModelErrors?) -> Void)?)
    func get(completion: ((User?, UserViewModelErrors?) -> Void)?)
    func getAvatar(completion: ((String?, UserViewModelErrors?) -> Void)?)
    func update(username: String?, email: String?, ava: Data?, avaName: String?, password: String?,
                completion: ((UserViewModelErrors?) -> Void)?)
    func logout(completion: ((UserViewModelErrors?) -> Void)?)
}
