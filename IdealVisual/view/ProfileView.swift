//
//  ProfileView.swift
//  IdealVisual
//
//  Created by a.kurganova on 03/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol ProfileDelegate: class {
    func profile()
}

class ProfileView: UIView {
    weak var delegateProfile: ProfileDelegate?
    func setup() {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = .up
        swipe.addTarget(self, action: #selector(closeProfile))
        self.addGestureRecognizer(swipe)
    }
    
    @objc func closeProfile() {
        self.removeFromSuperview()
    }
    
}
