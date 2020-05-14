//
// Created by a.kurganova on 08.05.2020.
// Copyright (c) 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import CoreML
import Vision

final class CoreMLManager {
    // MARK: create ML model
    func createCoreMLModel(completion: ((VNCoreMLModel?, CoreMLErrors?) -> Void)?) {
        do {
            let model = try VNCoreMLModel(for: IdealVisualClassifier_1().model)
            completion?(model, nil)
        } catch {
            Logger.log("can't create model")
            completion?(nil, CoreMLErrors.createModel)
        }
    }
}
