//
//  User.swift
//  IdealVisual
//
//  Created by a.kurganova on 02.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct User {
    let username: String?
    let email: String?
    let password: String?
}

let user = [
    User(username: "ketnipz", email: nil, password: nil),
    User(username: nil, email: "ketnipz@mail.ru", password: nil)
]
