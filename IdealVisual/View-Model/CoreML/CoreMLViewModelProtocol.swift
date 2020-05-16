//
//  CoreMLViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

protocol CoreMLViewModelProtocol: class {
    func makeClassificationRequest(completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?)
}
