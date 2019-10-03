//
//  Buttons.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

func CreateButton(image: UIImage?) -> UIView {
    let back = UIView()
    let imagev = UIImageView()
    imagev.image = image
    back.translatesAutoresizingMaskIntoConstraints = false
    back.widthAnchor.constraint(equalToConstant: 35).isActive = true
    back.heightAnchor.constraint(equalToConstant: 35).isActive = true
    back.layer.cornerRadius = 10
    back.backgroundColor = UIColor(red: 255/255, green: 209/255, blue: 140/255, alpha: 1.0)
    back.addSubview(imagev)
    imagev.translatesAutoresizingMaskIntoConstraints = false
    imagev.centerXAnchor.constraint(equalTo: back.safeAreaLayoutGuide.centerXAnchor).isActive = true
    imagev.centerYAnchor.constraint(equalTo: back.safeAreaLayoutGuide.centerYAnchor).isActive = true
    imagev.widthAnchor.constraint(equalToConstant: 20).isActive = true
    imagev.heightAnchor.constraint(equalToConstant: 20).isActive = true
    return back
}
