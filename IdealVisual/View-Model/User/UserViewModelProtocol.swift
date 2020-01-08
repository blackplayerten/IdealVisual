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
    func create(username: String, email: String, password: String, completion: ((ErrorViewModel?) -> Void)?)
    func login(email: String, password: String, completion: ((ErrorViewModel?) -> Void)?)
    func get(completion: ((User?, ErrorViewModel?) -> Void)?)
    func getAvatar(completion: ((String?, ErrorViewModel?) -> Void)?)
    func update(username: String?, email: String?, ava: Data?, avaName: String?, password: String?,
                completion: ((ErrorViewModel?) -> Void)?)
    func logout(completion: ((ErrorViewModel?) -> Void)?)
}
