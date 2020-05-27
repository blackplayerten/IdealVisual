//
//  UserViewModelErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

// MARK: - user errors
enum UserViewModelErrors: Error {
    case noConnection
    case ok
    case noData
    case unauthorized
    case notFound
    case usernameAlreadyExists
    case usernameLengthIsWrong
    case emailAlreadyExists
    // check validation if this error happens
    case emailFormatIsWrong
    case passwordLengthIsWrong
    case filesystemSave
    case wrongCredentials
    case unknown
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
enum PostViewModelErrors: Error {
    case noConnection
    case ok
    case noData
    case noID
    case notFound
    case unauthorized
    case cannotCreate
    case unknown
}

// MARK: - core ml errors
enum CoreMLViewModelErrors: Error {
    case createModel
    case noResults
    case resultsType
    case emptyIdentifier
    case unknown
}
