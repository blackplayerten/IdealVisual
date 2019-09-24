//
//  ViewController.swift
//  IdealVisual
//
//  Created by a.kurganova on 02/09/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    private func setup() {
        let virtual = VirtualVC()
        virtual.tabBarItem = UITabBarItem(title: "Virtual", image: UIImage(named: "vinst")?.withRenderingMode(.alwaysOriginal), tag: 1)
        viewControllers = [
            UINavigationController(rootViewController: virtual),
        ]
    }
}

