//
//  ClassificationStruct.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct ImageWithNameStruct {
    var imageName: String
    var image: UIImage

    init(imageName: String, image: UIImage) {
        self.imageName = imageName
        self.image = image
    }
}

struct ClassificationStruct {
    var animal: [ImageWithNameStruct]
    var food: [ImageWithNameStruct]
    var people: [ImageWithNameStruct]

    init(animal: [ImageWithNameStruct], food: [ImageWithNameStruct], people: [ImageWithNameStruct]) {
        self.animal = animal
        self.food = food
        self.people = people
    }
}
