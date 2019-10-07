//
//  Buttons.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let orange = UIColor(red: 0.85, green: 0.41, blue: 0.28, alpha: 1)
    static let light_gray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    static let dark_gray = UIColor(red: 0.32, green: 0.32, blue: 0.31, alpha: 1)
}

class ImageButton: UIView {
    init(image: UIImage, side: CGFloat = 35, target: Any, action: Selector, buttonColor: UIColor? = nil) {
        super.init(frame: .zero)
        let back = UIButton(type: .system)
        back.addTarget(target, action: action, for: .touchUpInside)
        let imagev = UIImageView()
        imagev.image = image
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: side).isActive = true
        self.heightAnchor.constraint(equalToConstant: side).isActive = true
        self.layer.cornerRadius = 10
        self.backgroundColor = buttonColor
        
        self.addSubview(back)
        back.translatesAutoresizingMaskIntoConstraints = false
        back.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        back.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        back.widthAnchor.constraint(equalTo: self.safeAreaLayoutGuide.widthAnchor).isActive = true
        back.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        self.addSubview(imagev)
        imagev.translatesAutoresizingMaskIntoConstraints = false
        imagev.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imagev.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor).isActive = true
        imagev.widthAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
        imagev.heightAnchor.constraint(equalToConstant: 0.7 * side).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
