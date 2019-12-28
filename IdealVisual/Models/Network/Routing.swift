//
//  Routing.swift
//  IdealVisual
//
//  Created by a.kurganova on 28.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

final class NetworkURLS {
    static let apiPath = "http://127.0.0.1:8080/api/"
    static let staticPath = "http://127.0.0.1:8080/static/"

    static let createUserURL = URL(string: apiPath + "signup")
    static let loginUserURL = URL(string: apiPath + "login")
    static let updateUserURL = URL(string: apiPath + "update")
    static let deleteUserURL = URL(string: apiPath + "session")
    static let postsURL = URL(string: apiPath + "post")
    static let staticURL = URL(string: staticPath)
    static let upload = URL(string: apiPath + "upload")
}
