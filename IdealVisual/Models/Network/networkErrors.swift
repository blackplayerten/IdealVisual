//
//  networkErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct NetworkError {
    let name: String
    let description: Any?

    init(name: String, description: Any? = nil) {
        self.name = name
        self.description = description
    }
}

struct ErrorsNetwork {
    static let noConnection: String = "no internet connection"

    static let okay: String = "ok"
    static let noData: String = "noData"
    static let unauthorized: String = "unauthorized"
    static let notFound: String = "not found"
    static let wrongFields: String = "wrong fields"
    static let forbidden: String = "forbidden"
}
