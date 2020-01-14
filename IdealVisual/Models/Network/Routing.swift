//
//  Routing.swift
//  IdealVisual
//
//  Created by a.kurganova on 28.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

final class NetworkURLS {
//    for debugging
//    static let apiPath = "http://127.0.0.1/api/"
//    static let staticPath = "http://127.0.0.1/static/"

    static let apiPath = "https://ideal-visual.ru/api/"
    static let staticPath = "https://ideal-visual.ru/static/"

    static let sessionURL = URL(string: apiPath + "session")
    static let accountURL = URL(string: apiPath + "account")
    static let postsURL = URL(string: apiPath + "post")
    static let staticURL = URL(string: staticPath)
    static let upload = URL(string: apiPath + "upload")
}
