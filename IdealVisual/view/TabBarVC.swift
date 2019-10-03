//
//  ViewController.swift
//  IdealVisual
//
//  Created by a.kurganova on 02/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit
import ESTabBarController_swift

class TabBar: ESTabBarController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    private func setup() {
        tabBar.isTranslucent = false
        tabBar.backgroundColor = .white
        
        tabBar.layer.masksToBounds = true
        tabBar.layer.borderColor = UIColor.lightGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.layer.cornerRadius = 20
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        let v1 = VirtualVC()
        v1.tabBarItem = ESTabBarItem(BouncingTabBarItem(), image: UIImage(named: "home"), selectedImage: UIImage(named: "home_select"), tag: 1)
        let v2 = UIButton()
        v2.adjustsImageWhenHighlighted = false
        v2.sizeToFit()
        v2.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(v2)
        v2.widthAnchor.constraint(equalToConstant: 25).isActive = true
        v2.heightAnchor.constraint(equalToConstant: 25).isActive = true
        tabBar.centerXAnchor.constraint(equalTo: v2.centerXAnchor).isActive = true
        tabBar.centerYAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.centerYAnchor).isActive = true
        v2.topAnchor.constraint(equalTo: tabBar.safeAreaLayoutGuide.centerYAnchor, constant: -13).isActive = true
        let add = UIImage(named: "add")
        let add_select = UIImage(named: "add_select")
        v2.setBackgroundImage(add, for: .normal)
        v2.setBackgroundImage(add_select, for: .selected)
//        v2.addTarget(self, action: #selector(<#T##@objc method#>), for: <#T##UIControl.Event#>)
        
        let v3 = ProfileView()
        v3.tabBarItem = ESTabBarItem(BouncingTabBarItem(), image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile_select"), tag: 3)

        viewControllers = [
            UINavigationController(rootViewController: v1),
            UINavigationController(rootViewController: v3),
        ]
    }
}

