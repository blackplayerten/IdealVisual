//
//  GetAvatarUser.swift
//  IdealVisual
//
//  Created by a.kurganova on 04.12.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit

final class MyFileManager {
    static func resolveAbsoluteFilePath(filePath: String) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let searchHome = URL(fileURLWithPath: documentsDirectory)

        return searchHome.appendingPathComponent(filePath)
    }

    static func saveFile(data: Data, filePath: String) -> URL? {
        if filePath == "" {
            return nil
        }

        let absoluteFilePath = resolveAbsoluteFilePath(filePath: filePath)
        let folder = absoluteFilePath.deletingLastPathComponent()

        if !FileManager.default.fileExists(atPath: folder.path) {
            do {
                try FileManager.default.createDirectory(atPath: folder.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                Logger.log(error.localizedDescription)
            }
        }

        if !FileManager.default.fileExists(atPath: absoluteFilePath.path) {
            do {
                try data.write(to: absoluteFilePath)
                print("file was saved to folder \(absoluteFilePath)")
            } catch {
                print("file wasn't saved to folder \(absoluteFilePath), because \(error)")
                return nil
            }
        }

        return absoluteFilePath
    }

    static func getFile(filePath: String) -> Data? {
        let absoluteFilePath = resolveAbsoluteFilePath(filePath: filePath)
        let data = FileManager.default.contents(atPath: absoluteFilePath.path)
        return data
    }

    static func deleteFile(filePath: String) {
        do {
            let absoluteFilePath = resolveAbsoluteFilePath(filePath: filePath)
            try FileManager.default.removeItem(at: absoluteFilePath)
            print("file was deleted from folder \(filePath)")
        } catch {
            print("file wasn't removed from folder \(filePath), because \(error)")
        }
    }

    static func deleteDirectoriesFromAppDirectory() {
        let myDocuments = resolveAbsoluteFilePath(filePath: "")
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: myDocuments, includingPropertiesForKeys: [.isDirectoryKey])
            try files.forEach {
                if try $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory! {
                    try FileManager.default.removeItem(at: $0)
                }
            }
        } catch {
            Logger.log("cannot clean documentDirectory")
            return
        }
    }
}
