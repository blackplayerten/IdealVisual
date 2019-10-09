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
        self.tabBar.layer.borderColor = Colors.dark_gray.cgColor
        self.tabBar.layer.borderWidth = 0.2
        let main = MainView()
        guard let im = UIImage(named: "add_tabbar")?.withRenderingMode(.alwaysOriginal) else { return }
        main.tabBarItem = UITabBarItem(title: nil, image: im, tag: 0)

        viewControllers = [
            UINavigationController(rootViewController: main)
        ]
    }
}

extension UITabBar {
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
    var sizeThatFits = super.sizeThatFits(size)
    sizeThatFits.height = 70
    return sizeThatFits
   }
}
