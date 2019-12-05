//
//  GetAvatarUser.swift
//  IdealVisual
//
//  Created by a.kurganova on 04.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

class GetAvatarUser {
    private static var searchDirectory: URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return URL(fileURLWithPath: documentsDirectory)
    }

    static func urlUserAvatar(urlToAva: String) -> URL {
        return searchDirectory.appendingPathComponent(urlToAva)
    }

    static func setAvatarUser(nameAvatarByUrl: String, place: UIImageView?) -> String? {
        if nameAvatarByUrl != "" {
            print("est ava")
            let pathAvaUser = GetAvatarUser.urlUserAvatar(urlToAva: nameAvatarByUrl)
            let pathFromNameAva = pathAvaUser.path
            if place != nil {
                place?.image = UIImage(contentsOfFile: pathFromNameAva)
            }
            return pathFromNameAva
        } else {
            print("no ava")
            let name = "default_profile"
            place?.image = UIImage(named: name)
            return name
        }
    }
}
