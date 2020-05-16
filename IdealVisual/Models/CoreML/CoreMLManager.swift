//
// Created by a.kurganova on 08.05.2020.
// Copyright (c) 2020 a.kurganova. All rights reserved.
//

import Foundation
import CoreML
import Vision

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
                                      completion: ((CategoriesType?, CoreMLErrorsModel?) -> Void)?) {
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

            DispatchQueue.main.async {
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
                    let topClassifications = classifications
                    _ = topClassifications.map { classification in
                        let identidier = String(classification.identifier)
                        switch identidier {
                        case "Животное":
                            completion?(CategoriesType.animal, nil)
                        case "Еда":
                            completion?(CategoriesType.food, nil)
                        case "Человек":
                            completion?(CategoriesType.people, nil)
                        default:
                            Logger.log("unknown identifier: \(identidier)")
                            completion?(CategoriesType.another, nil)
                        }
                    }
                }
            }
        })
        request.imageCropAndScaleOption = .centerCrop
    }

//    func kek(request: VNRequest, completion: ((VNRequest?, Error?) -> Void)?) {
//        DispatchQueue.main.async {
//            guard let results = request.results else {
//                Logger.log("unable to classify image")
//                completion?(nil, CoreMLErrorsModel.noResults)
//                return
//            }
//
//            guard let classifications = results as? [VNClassificationObservation] else {
//                Logger.log("non-vnclassificationobservation type results")
//                completion?(nil, CoreMLErrorsModel.resultsType)
//                return
//            }
//
//            if classifications.isEmpty {
//                Logger.log("nothing recognized")
//                completion?(nil, CoreMLErrorsModel.noResults)
//            } else {
//                // Display top classifications ranked by confidence in the UI.
//                let topClassifications = classifications.prefix(2)
//                let descriptions = topClassifications.map { classification in
//                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
//                   return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
//                }
//                Logger.log("Classification:\n" + descriptions.joined(separator: "\n"))
////                request.imageCropAndScaleOption = .centerCrop
//                completion?(request, nil)
//            }
//        }
//    }
}
