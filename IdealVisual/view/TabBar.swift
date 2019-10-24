//
//  TabBar.swift
//  IdealVisual
//
//  Created by a.kurganova on 07/10/2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class TabBar: UITabBarController, UITabBarControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        self.tabBar.barTintColor = .white
        tabBar.clipsToBounds = true
        
        let main = MainView()
        let image = UIImage(named: "add_tabbar")?.withRenderingMode(.alwaysOriginal)
        main.tabBarItem = UITabBarItem(title: nil, image: image, tag: 0)
        main.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        viewControllers = [
            UINavigationController(rootViewController: main)
        ]
    }
}
