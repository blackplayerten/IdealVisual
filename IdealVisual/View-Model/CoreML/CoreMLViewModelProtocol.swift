//
//  CoreMLViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import Vision

protocol CoreMLViewModelProtocol: class {
    func createMLModel(completion: ((VNCoreMLModel?, CoreMLViewModelErrors?) -> Void)?)
    func makeClassificationRequest(image: UIImage, completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?)
}
