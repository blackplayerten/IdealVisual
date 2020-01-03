//
//  UserViewModelErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

typealias ErrorViewModel = String

struct ErrorsUserViewModel {
    static let ok: ErrorViewModel = "ok"
    static let noData: ErrorViewModel = "user has no data"
    static let unauthorized: ErrorViewModel = "user unauthorized"
    static let notFound: ErrorViewModel = "user not found"
    static let alreadyExists: ErrorViewModel = "user already exists"

    static let filesystemSave: ErrorViewModel = "can't save file"
}

struct ErrorsPostViewModel {
    static let ok: ErrorViewModel = "ok"
    static let noData: ErrorViewModel = "post has no data"
    static let noID: ErrorViewModel = "post has no id"
    static let notFound: ErrorViewModel = "post not found"
}
