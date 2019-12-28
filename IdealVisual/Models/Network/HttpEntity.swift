//
//  httpEntity.swift
//  IdealVisual
//
//  Created by a.kurganova on 23.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct HTTPMethods {
    static let get = "GET"
    static let post = "POST"
    static let put = "PUT"
    static let delete = "DELETE"
}

struct HTTPCodes {
    static let okay = 200
    static let noData = 204
    static let unauthorized = 401
    static let notFound = 404
    static let alreadyExists = 409
}
