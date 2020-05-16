//
//  CoreMLViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol CoreMLViewModelProtocol: class {
    func makeClassificationRequest(image: UIImage, completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?)
}
