//
//  networkErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

typealias NetworkError = String

struct ErrorsNetwork {
    static let okay: String = "ok"
    static let noData: String = "noData"
    static let unauthorized: String = "unauthorized"
    static let notFound: String = "not found"
    static let alreadyExists: String = "already exists"
}
