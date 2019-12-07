//
//  DarkFontNavigationController.swift
//  IdealVisual
//
//  Created by a.kurganova on 12.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class DarkFontNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
}
