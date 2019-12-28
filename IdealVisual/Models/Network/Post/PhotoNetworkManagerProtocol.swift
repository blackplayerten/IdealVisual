//
//  PhotoNetworkProtocol.swift
//  IdealVisual
//
//  Created by a.kurganova on 26.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation

protocol PhotoNetworkManagerProtocol {
    func getPhoto(path: String, completion: ((Data?, NetworkError?) -> Void)?)
    func upload(data: Data, completion: ((String?, NetworkError?) -> Void)?)
}
