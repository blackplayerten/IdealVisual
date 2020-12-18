//
//  Posts.swift
//  IdealVisual
//
//  Created by Alexandra Kurganova on 18.12.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import SQLite

final class PostTable {
    static func all() -> [Post] {
        var posts = [Post]()
        do {
            for post in try DataBase.shared.connection.run(
                "SELECT _id, id, photo, date, place, text, index_photo, last_updated FROM post"
            ) {
                posts.append(Post(
                    _id: post[0] as! Int64,
                    id: UUID(uuidString: post[1] as! String)!,
                    photo: post[2] as! String,
                    date: convertToDate(post[3] as? String),
                    place: post[4] as? String,
                    text: post[5] as? String,
                    indexPhoto: post[6] as! Int64,
                    lastUpdated: convertToDate(post[7] as? String)
                ))
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }

        return posts
    }

    private static func convertToDate(_ strDate: String?) -> Date? {
        if let strDate = strDate {
            return dateFormatter.date(from: strDate)
        }
        return nil
    }
}
