//
//  UserViewModelErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

typealias ErrorViewModel = String

// MARK: - user errors
struct ErrorsUserViewModel {
    static let noConnection: String = "no internet connection"

    static let ok: ErrorViewModel = "ok"
    static let noData: ErrorViewModel = "user has no data"
    static let unauthorized: ErrorViewModel = "user unauthorized"
    static let notFound: ErrorViewModel = "user not found"

    static let usernameAlreadyExists: ErrorViewModel = "user already exists"
    static let usernameLengthIsWrong: ErrorViewModel = "username length is wrong"

    static let emailAlreadyExists: ErrorViewModel = "email already exists"
    static let emailFormatIsWrong: ErrorViewModel = "email format is wrong" // check validation if this error happens

    static let passwordLengthIsWrong: ErrorViewModel = "password length is wrong"

    static let filesystemSave: ErrorViewModel = "can't save file"

    static let wrongCredentials: ErrorViewModel = "wrong email-password pair"

    // just in case our error handling is wrong
    static let unknownError: ErrorViewModel = "unknown error"
}

// MARK: - sign in, sugn up errors

struct FieldErrors {
    var field: String
    var reasons: [String]
}

struct SignUpInFields {
    static let username: String = "username"
    static let email: String = "email"
    static let password: String = "password"
}

struct SignUpInReasons {
    static let alreadyExists: String = "already_exists"
    static let wrongLength: String = "wrong_len"
    static let wrongEmail: String = "not_email"
}

// MARK: - post errors
struct ErrorsPostViewModel {
    static let noConnection: ErrorViewModel = "no internet connection"

    static let ok: ErrorViewModel = "ok"
    static let noData: ErrorViewModel = "post has no data"
    static let noID: ErrorViewModel = "post has no id"

    static let notFound: ErrorViewModel = "post not found"

    static let unauthorized: ErrorViewModel = "user unauthorized"
    static let cannotCreate: ErrorViewModel = "cannot create post"

    static let unknownError: ErrorViewModel = "unknown error"
}
