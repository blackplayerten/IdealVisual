//
//  PhotoRoundedDecorator.swift
//  IdealVisual
//
//  Created by Sasha Kurganova on 19.03.2021.
//  Copyright © 2021 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol iPhotoEditor {
    func apply() -> UIImageView
}

final class PhotoRoundedDecorator: iPhotoEditor {
    private let photoEditor: iPhotoEditor

    init(_ photoEditor: iPhotoEditor) {
        self.photoEditor = photoEditor
    }
    
    func apply() -> UIImageView {
        let photo = photoEditor.apply()
        photo.contentMode = .scaleAspectFill
        photo.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner, .layerMinXMinYCorner]
        photo.layer.cornerRadius = 10
        photo.layer.masksToBounds = true
        return photo
    }
}

extension UIImageView: iPhotoEditor {
    func apply() -> UIImageView {
        return self
    }
}
