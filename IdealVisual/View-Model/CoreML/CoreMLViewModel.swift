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

    func makeClassificationRequest(image: UIImage, completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?) {
        coreMLModelManager.createCoreMLModel(completion: { [weak self] (model, error) in
            if let err = error {
                switch err {
                case .createModel:
                    completion?(nil, CoreMLViewModelErrors.createModel)
                default:
                    completion?(nil, CoreMLViewModelErrors.unknown)
                }
            }
            guard let model = model else {
                Logger.log("model is empty")
                completion?(nil, CoreMLViewModelErrors.createModel)
                return
            }
            self?.model = model
        })

        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
        guard let ciImage = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).")
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([
                    self.coreMLModelManager.create_classificasionRequest(model: self.model!,
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
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}
