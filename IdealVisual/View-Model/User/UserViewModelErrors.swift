//
//  UserViewModelErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

typealias ErrorViewModel  = String

struct ErrorsUserViewModel {
    static let okay: String = "ok"
    static let noData: String = "user has no data"
    static let unauthorized: String = "user unauthorized"
    static let notFound: String = "user not found"
    static let alreadyExists: String = "user already exists"

    static let filesystemSave: String = "can't save file"
}
