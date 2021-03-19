//
//  PhotoCacheDecorator.swift
//  IdealVisual
//
//  Created by Sasha Kurganova on 19.03.2021.
//  Copyright © 2021 a.kurganova. All rights reserved.
//

import Foundation

class PhotoCacheDecorator: PhotoNetworkManagerProtocol {
    private let service: PhotoNetworkManagerProtocol
    private var cache: [String: Data]
    private var lastInvalidateTime: Date

    init(_ service: PhotoNetworkManagerProtocol) {
        self.service = service
        self.cache = [String: Data]()
        self.lastInvalidateTime = Date()
    }

    func get(path: String, completion: ((Data?, NetworkError?) -> Void)?) {
        let data = self.cache[path]
        if let data = data {
            completion?(data, nil)
            return
        }
        
        self.service.get(path: path) { [weak self] (data, error) in
            guard let self = self else { return }

            let now = Date()
            if self.lastInvalidateTime.timeIntervalSince(now) > TimeInterval(15 * 60) /* 15 min */ {
                self.cache.removeAll()
                self.lastInvalidateTime = now
            }
            
            if let data = data {
                self.cache[path] = data
            }
            completion?(data, error)
        }
    }

    func upload(token: String, data: Data, name: String, completion: ((String?, NetworkError?) -> Void)?) {
        self.service.upload(token: token, data: data, name: name, completion: completion)
    }
}
