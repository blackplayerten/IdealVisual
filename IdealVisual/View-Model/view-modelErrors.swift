//
//  UserViewModelErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

//struct ErrorViewModel: Error {
//    let name: String
//
//    static func == (left: ErrorViewModel, right: ErrorViewModel) -> Bool {
//        return left.name == right.name
//    }
//}

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
//struct ErrorsUserViewModel {
//    static let noConnection: ErrorViewModel = ErrorViewModel(name: "no internet connection")
//
//    static let ok: ErrorViewModel = ErrorViewModel(name: "ok")
//    static let noData: ErrorViewModel = ErrorViewModel(name: "user has no data")
//    static let unauthorized: ErrorViewModel = ErrorViewModel(name: "user unauthorized")
//    static let notFound: ErrorViewModel = ErrorViewModel(name: "user not found")
//
//    static let usernameAlreadyExists: ErrorViewModel = ErrorViewModel(name: "user already exists")
//    static let usernameLengthIsWrong: ErrorViewModel = ErrorViewModel(name: "username length is wrong")
//
//    static let emailAlreadyExists: ErrorViewModel = ErrorViewModel(name: "email already exists")
//
//    // check validation if this error happens
//    static let emailFormatIsWrong: ErrorViewModel = ErrorViewModel(name: "email format is wrong")
//
//    static let passwordLengthIsWrong: ErrorViewModel = ErrorViewModel(name: "password length is wrong")
//
//    static let filesystemSave: ErrorViewModel = ErrorViewModel(name: "can't save file")
//
//    static let wrongCredentials: ErrorViewModel = ErrorViewModel(name: "wrong email-password pair")
//
//    // just in case our error handling is wrong
//    static let unknownError: ErrorViewModel = ErrorViewModel(name: "unknown error")
//}

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
//enum ErrorsPostViewModel: Error {
//    case noConnection
//
////    static let ok: ErrorViewModel = ErrorViewModel(name: "ok")
////    static let noData: ErrorViewModel = ErrorViewModel(name: "post has no data")
////    static let noID: ErrorViewModel = ErrorViewModel(name: "post has no id")
////
////    static let notFound: ErrorViewModel = ErrorViewModel(name: "post not found")
////
////    static let unauthorized: ErrorViewModel = ErrorViewModel(name: "user unauthorized")
////    static let cannotCreate: ErrorViewModel = ErrorViewModel(name: "cannot create post")
////
////    static let unknownError: ErrorViewModel = ErrorViewModel(name: "unknown error")
//}
