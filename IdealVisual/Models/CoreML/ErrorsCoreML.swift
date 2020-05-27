//
//  ErrorsCoreML.swift
//  IdealVisual
//
//  Created by a.kurganova on 10.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

enum CoreMLErrorsModel: Error {
    case createModel
    case noResults
    case resultsType
    case unknownIdentifier
    case unknown
}
