//
//  CoreMLViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import Vision
import UIKit

final class CoreMLViewModel: CoreMLViewModelProtocol {
    private let coreMLModelManager: CoreMLManagerProtocol
    private var model: VNCoreMLModel?

    init() {
        self.coreMLModelManager = CoreMLManager()
    }

    func createMLModel(completion: ((VNCoreMLModel?, CoreMLViewModelErrors?) -> Void)?) {
        coreMLModelManager.createCoreMLModel(completion: { [weak self] (model, error) in
            if let err = error {
                switch err {
                case .createModel:
                    completion?(nil, CoreMLViewModelErrors.createModel)
                    return
                default:
                    completion?(nil, CoreMLViewModelErrors.unknown)
                    return
                }
            }
            guard let model = model else {
                Logger.log("model is empty")
                completion?(nil, CoreMLViewModelErrors.createModel)
                return
            }
            self?.model = model
            completion?(model, nil)
        })
    }

    func makeClassificationRequest(image: UIImage, completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?) {
        guard let model = self.model else {
            completion?(nil, CoreMLViewModelErrors.createModel)
            return
        }

        let orientation = UIImageOrientationToCGImagePropertyOrientation(orientation: image.imageOrientation)
        guard let ciImage = CIImage(image: image) else {
            Logger.log("Unable to create \(CIImage.self) from \(image).")
            completion?(nil, CoreMLViewModelErrors.unknown)
            return
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
            try handler.perform([
                self.coreMLModelManager.create_classificasionRequest(model: model,
                                                                     completion: { (identifier, error) in
                    if let err = error {
                        switch err {
                        case .noResults:
                            completion?(nil, CoreMLViewModelErrors.noResults)
                        case .resultsType:
                            completion?(nil, CoreMLViewModelErrors.resultsType)
                        default:
                            completion?(nil, CoreMLViewModelErrors.unknown)
                        }
                    }

                    guard let identifier = identifier else {
                        Logger.log("identifier is empty")
                        completion?(nil, CoreMLViewModelErrors.emptyIdentifier)
                        return
                    }

                    completion?(identifier, nil)
                })
            ])
        } catch {
            if let err = error as? CoreMLErrorsModel {
                switch err {
                case .noResults:
                    completion?(nil, CoreMLViewModelErrors.noResults)
                case .resultsType:
                    completion?(nil, CoreMLViewModelErrors.resultsType)
                case .createModel:
                    completion?(nil, CoreMLViewModelErrors.createModel)
                case .unknownIdentifier:
                    completion?(nil, CoreMLViewModelErrors.emptyIdentifier)
                default:
                    Logger.log("Failed to perform classification.\n\(error.localizedDescription)")
                    completion?(nil, CoreMLViewModelErrors.unknown)
                }
            } else {
                Logger.log("Failed to perform classification.\n\(error.localizedDescription)")
                completion?(nil, CoreMLViewModelErrors.unknown)
            }
        }
    }
}

func UIImageOrientationToCGImagePropertyOrientation(orientation: UIImage.Orientation) -> CGImagePropertyOrientation {
    switch orientation {
    case .up:
        return .up
    case .upMirrored:
        return .upMirrored
    case .down:
        return .down
    case .downMirrored:
        return .downMirrored
    case .leftMirrored:
        return .leftMirrored
    case .right:
        return .right
    case .rightMirrored:
        return .rightMirrored
    case .left:
        return .left
    }
}
