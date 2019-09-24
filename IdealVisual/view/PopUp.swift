//
//  PopUp.swift
//  IdealVisual
//
//  Created by a.kurganova on 23/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol PopUpDelegate: class {
    func choose_photo()
}

class PopUp: UIView {
    weak var delegatePopUp: PopUpDelegate?
    let photo = UIButton()
    private var opened: Bool = false
    private var photos = [UIImage]()

    func show() {
        if opened {
            removeFromSuperview()
        } else {
            addSubview(photo)
            photo.translatesAutoresizingMaskIntoConstraints = false
            photo.setBackgroundImage(UIImage(named: "photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
            photo.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            photo.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
            photo.addTarget(self, action: #selector(chooseHandler), for: .touchUpInside)
        }
        opened = !opened
    }
    
    @objc private func chooseHandler() {
        delegatePopUp?.choose_photo()
    }
}
