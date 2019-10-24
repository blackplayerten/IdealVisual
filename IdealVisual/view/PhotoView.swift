//
//  PhotoView.swift
//  IdealVisual
//
//  Created by a.kurganova on 24.10.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class PhotoView: UIViewController {
    var publication: Photo?
    let photo = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .none
        
        view.backgroundColor = .white
        tabBarController?.tabBar.isHidden = true
        
        view.addSubview(photo)
        photo.translatesAutoresizingMaskIntoConstraints = false
        photo.widthAnchor.constraint(equalToConstant: 375).isActive = true
        photo.heightAnchor.constraint(equalToConstant: 375).isActive = true
        photo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        photo.image = publication?.photo
        
    }
}
