//
//  StructuresNetwork.swift
//  IdealVisual
//
//  Created by a.kurganova on 13.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

struct JsonToken: Decodable {
    var token: String = ""
}

struct JsonUserModel: Codable {
    var token: String?
    var id: Int?
    var username: String = ""
    var email: String = ""
    var password: String?
    var avatar: String?
}

struct JsonPostModel: Codable {
    var id: UUID = UUID()
    var photo: String = ""
    var photoIndex: Int64?
    var date: Date = Date(timeIntervalSince1970: 0)
    var place: String = ""
    var text: String = ""
    var lastUpdated: Date = Date()
}

struct JsonError: Decodable {
    var errors: [JsonFieldError]
}

struct JsonFieldError: Decodable {
    var field: String
    var reasons: [String]
}

struct JsonUploadedPhotoTo: Decodable {
    var path: String
}
