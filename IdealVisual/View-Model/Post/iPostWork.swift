//
//  PhotoViewModelProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 27.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

protocol iPostWork {
    func update(post: Post, date: Date?, place: String?, text: String?,
                completion: ((PostViewModelErrors?) -> Void)?)
}
