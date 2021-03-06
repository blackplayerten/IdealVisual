//
//  File.swift
//  IdealVisual
//
//  Created by a.kurganova on 21.05.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation

protocol MainViewAddPostsDelegate: class {
    func create(photoName: String, photoData: Data?, date: Date?, place: String?, text: String?,
                completion: ((PostViewModelErrors?) -> Void)?)
}
