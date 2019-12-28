//
//  Errors.swift
//  IdealVisual
//
//  Created by a.kurganova on 17.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

func errorProcessing(error: ResponseError) {
    switch error {
    case "user is already exists":
        print("error usera")
    // render label with this error
    default:
    break
    }
}
