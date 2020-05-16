//
//  CoreMLManagerProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import CoreML
import Vision

protocol CoreMLManagerProtocol: class {
    func createCoreMLModel(completion: ((VNCoreMLModel?, CoreMLErrorsModel?) -> Void)?)
    func create_classificasionRequest(model: VNCoreMLModel,
                                      completion: ((CategoriesType?, CoreMLErrorsModel?) -> Void)?)
}
