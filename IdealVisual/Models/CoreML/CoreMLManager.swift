//
// Created by a.kurganova on 08.05.2020.
// Copyright (c) 2020 a.kurganova. All rights reserved.
//

import Foundation
import CoreML
import Vision
import UIKit

final class CoreMLManager: CoreMLManagerProtocol {
    // MARK: create ML model
    func createCoreMLModel(completion: ((VNCoreMLModel?, CoreMLErrorsModel?) -> Void)?) {
        do {
            let model = try VNCoreMLModel(for: IdealVisualClassifier_1().model)
            completion?(model, nil)
        } catch {
            Logger.log("can't create model")
            completion?(nil, CoreMLErrorsModel.createModel)
        }
    }

    // MARK: classification request
    func create_classificasionRequest(model: VNCoreMLModel,
                                      completion: ((CategoriesType?, CoreMLErrorsModel?) -> Void)?) -> VNCoreMLRequest {
        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if let err = error as? CoreMLErrorsModel {
                switch err {
                case .noResults:
                    completion?(nil, CoreMLErrorsModel.noResults)
                case .resultsType:
                    completion?(nil, CoreMLErrorsModel.resultsType)
                default:
                    completion?(nil, CoreMLErrorsModel.unknown)
                }
            }

            //DispatchQueue.main.async {
                guard let results = request.results else {
                    Logger.log("unable to classify image")
                    completion?(nil, CoreMLErrorsModel.noResults)
                    return
                }

                guard let classifications = results as? [VNClassificationObservation] else {
                    Logger.log("non-vnclassificationobservation type results")
                    completion?(nil, CoreMLErrorsModel.resultsType)
                    return
                }

                if classifications.isEmpty {
                    Logger.log("nothing recognized")
                    completion?(nil, CoreMLErrorsModel.noResults)
                } else {
                    classifications.first.map { classification in
                        print(classification.confidence)
                        if classification.confidence >= 0.8 {
                            let identidier = String(classification.identifier)
                            switch identidier {
                            case "animals":
                                completion?(CategoriesType.animal, nil)
                            case "food":
                                completion?(CategoriesType.food, nil)
                            case "people":
                                completion?(CategoriesType.people, nil)
                            default:
                                Logger.log("unknown identifier: \(identidier)")
                                completion?(CategoriesType.another, nil)
                            }
                        }
                    }
                }
            }
        //}
        )
        request.imageCropAndScaleOption = .centerCrop
        return request
    }
}
