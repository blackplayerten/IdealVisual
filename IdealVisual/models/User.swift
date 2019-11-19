//
//  User.swift
//  IdealVisual
//
//  Created by a.kurganova on 02.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct User {
    var username: String?
    var email: String?
    var password: String?
    var ava: UIImage?

    init(username: String? = nil, email: String? = nil, password: String? = nil, ava: UIImage? = nil) {
        self.username = username
        self.email = email
        self.password = password
        self.ava = ava
    }
}
