//
//  CoreMLViewModel.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import Vision

final class CoreMLViewModel {
    private let coreMLModelManager: CoreMLManagerProtocol
    private var model: VNCoreMLModel?
    
    init() {
        self.coreMLModelManager = CoreMLManager()
    }

    func makeClassificationRequest(completion: ((CategoriesType?, CoreMLViewModelErrors?) -> Void)?) {
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

        guard let model = model else {
            Logger.log("model is empty")
            completion?(nil, CoreMLViewModelErrors.createModel)
            return
        }

        coreMLModelManager.create_classificasionRequest(model: model, completion: { (identifier, error) in
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
    }
}
