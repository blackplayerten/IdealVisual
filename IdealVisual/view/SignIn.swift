//
//  SignIn.swift
//  IdealVisual
//
//  Created by a.kurganova on 05.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class SignIn: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setNav()
    }
    
    private func setNav() {
        let titleV = UILabel()
        view.addSubview(titleV)
        titleV.text = "IdealVisual"
        titleV.translatesAutoresizingMaskIntoConstraints = false
        titleV.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -30).isActive = true
        titleV.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        titleV.font = UIFont(name: "Montserrat-Bold", size: 35)
        titleV.adjustsFontSizeToFitWidth = true
        navigationController?.navigationItem.titleView = titleV
        
        let logo = UIImageView()
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "app")?.withRenderingMode(.alwaysOriginal)
        logo.widthAnchor.constraint(equalToConstant: 35).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 35).isActive = true
        logo.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 25).isActive = true
        logo.rightAnchor.constraint(equalTo: titleV.leftAnchor, constant: -20).isActive = true
        setAuth()
    }
    
    private func setAuth() {
        
    }
}
