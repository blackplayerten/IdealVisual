//
//  StructuresNetwork.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct JsonUserModel: Codable {
    var token: String = ""
    var usernameStr: String = ""
    var emailStr: String = ""
    var password: String = ""
    var ava: String = ""
}

struct JsonPostModel: Codable {
    var photoStr: String = ""
    var photoIndex: Int64 = 0
    var dateStr: Date = Date(timeIntervalSince1970: 0)
    var placeStr: String = ""
    var textStr: String = ""
}

struct JsonError: Codable {
    var field: [String: String] = ["": ""]
}
