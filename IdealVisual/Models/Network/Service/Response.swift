//
//  Response.swift
//  IdealVisual
//
//  Created by a.kurganova on 17.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

func responseCheck(response: HTTPURLResponse) -> ResponseError? {
    let status = response.statusCode
    print("response code: \(status)")
    switch status {
    case 200:
        break
    case 409:
        return "user already exist"
    default:
        return "unknown error: \(response.statusCode)"
    }
    return nil
}
