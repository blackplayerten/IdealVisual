//
//  ClassificationStruct.swift
//  IdealVisual
//
//  Created by a.kurganova on 16.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct ClassificationStruct {
    let animal: [UIImage]
    let food: [UIImage]
    let people: [UIImage]
    
    init(animal: [UIImage], food: [UIImage], people: [UIImage]) {
        self.animal = animal
        self.food = food
        self.people = people
    }
}
