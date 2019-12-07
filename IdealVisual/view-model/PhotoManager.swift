//
//  PhotoManager.swift
//  IdealVisual
//
//  Created by a.kurganova on 07.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

func getPhoto(namePhoto: String, typePhoto: TypePhoto) -> UIImage? {
    if namePhoto == "" {
        return UIImage(named: "default_profile")
    }

    let pathAvaUser = resolveAbsoluteFilePath(filePath: namePhoto)
    let imagePath = pathAvaUser.path

    switch typePhoto {
    case .avatar:
        if FileManager.default.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)
        } else {
            return UIImage(named: "default_profile")
        }
    case .post:
        if FileManager.default.fileExists(atPath: imagePath) {
            return UIImage(contentsOfFile: imagePath)
        }
    }

    return nil
}

func getFolderName(typePhoto: TypePhoto) -> String {
    switch typePhoto {
    case .avatar:
        return "avatars"
    case .post:
        return "posts"
    }
}

func savePhoto(photo: UIImage?, typePhoto: TypePhoto, fileName: String) -> URL? {
    let folder = getFolderName(typePhoto: typePhoto)

    // save image as url to selected directory
    if let data = photo?.jpegData(compressionQuality: 1.0) {
        return saveFile(data: data, filePath: folder + "/" + fileName)
    }

    return nil
}

func deletePhoto(filePath: URL) {

}
