//
//  networkErrors.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct WrongFieldsNetworkEror: Error {
    let name: String
    let description: Any

    init(name: String, description: Any) {
        self.name = name
        self.description = description
    }
}

enum NetworkError: Error {
    case noConnection
    case ok
    case noData
    case notFound
    case unauthorized
    case wrongFields(WrongFieldsNetworkEror)
    case forbidden
    case unknown
    case invalidURL
}

//struct ErrorsNetwork {
//    static let noConnection: String = "no internet connection"
//
//    static let okay: String = "ok"
//    static let noData: String = "noData"
//    static let unauthorized: String = "unauthorized"
//    static let notFound: String = "not found"
//    static let wrongFields: String = "wrong fields"
//    static let forbidden: String = "forbidden"
//}
