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
    static let unprocessableEntity = 422
    static let forbidden = 403
}

struct MyHTTPHeaders {
    static let authorization: String = "Authorization"
    static let contentType: String = "Content-Type"
}

struct Authorization {
    // authorization: Bearer <UUID>
    static let bearerToken: String = "Bearer "

    static func getBearerToken(token: String) -> String {
        return bearerToken + token
    }
}

struct MimeTypes {
    static let defaultMimeType = "application/octet-stream"
    static let appJSON = "application/json"
    static let mimeTypes = [
        "jpeg": "image/jpeg",
        "jpg": "image/jpeg",
        "png": "image/png"
    ]

    static func getFromExtension(ext: String) -> String {
        guard let mimeType = mimeTypes[ext] else {
            return defaultMimeType
        }

        return mimeType
    }
}

struct MultipartFormData {
    static func createBody(parameters: [String: String],
                           boundary: String,
                           data: Data,
                           mimeType: String,
                           filename: String) -> Data {
        let body = NSMutableData()

        let boundaryPrefix = "--\(boundary)\r\n"

        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }

        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))

        return body as Data
    }

    static func getContentTypeValue(boundary: String) -> String {
        return "multipart/form-data; boundary=\(boundary)"
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8, allowLossyConversion: false)
        append(data!)
    }
}
