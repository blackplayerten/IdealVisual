//
//  Requests.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol UserCoreDataProtocol: class {
    func create(token: String, username: String, email: String, ava: String?) -> User?
    func update(username: String?, email: String?, avatar: String?)
    func get() -> User?
    func delete()
}
