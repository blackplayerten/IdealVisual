//
//  BlockProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

protocol BlockProtocol: class {
    func updateBlock(from: BlockPost)

    func textViewShouldBeginEditing(block: BlockPost)
    func textViewShouldEndEditing(block: BlockPost)
}
