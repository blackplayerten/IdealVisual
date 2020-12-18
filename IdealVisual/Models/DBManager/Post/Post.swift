//
//  Post.swift
//  IdealVisual
//
//  Created by a.kurganova on 29.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import SQLite

final class Post {
    private var row_id: Int64 // local
    var id: UUID
    let feed: Int64 = 1
    var photo: String
    var date: Date?
    var place: String?
    var text: String?
    var indexPhoto: Int64
    var lastUpdated: Date?
    
    init(_id: Int64 = 0, id: UUID, photo: String, date: Date? = nil, place: String? = nil,
         text: String? = nil, indexPhoto: Int64, lastUpdated: Date? = nil) {
        self.row_id = 0
        self.id = id
        self.photo = photo
        self.date = date
        self.place = place
        self.text = text
        self.indexPhoto = indexPhoto
        self.lastUpdated = lastUpdated
    }
    
    func create() {
        do {
            try DataBase.shared.connection.transaction {
                try DataBase.shared.connection.run(
                    """
                    INSERT INTO post (id, feed, photo, date, place, text, index_photo, last_updated)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    [id.uuidString, feed, photo, convertDate(date), place, text, indexPhoto, convertDate(lastUpdated)]
                )
                for post in try DataBase.shared.connection.run("SELECT last_insert_rowid() FROM post") {
                    self.row_id = post[0] as! Int64
                }
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement)")
        } catch let error {
            Logger.log("insert failed: \(error)")
        }
    }
    
    func update() {
        do {
            let count = try DataBase.shared.connection.run(Update(
                "UPDATE post SET date = ?, place = ?, text = ?, index_photo = ?, last_updated = ? WHERE id = ?",
                [convertDate(date), place, text, indexPhoto, convertDate(lastUpdated), id.uuidString]
            ))
            if count == 0 {
                Logger.log("post not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement)")
        } catch let error {
            Logger.log("update failed: \(error)")
        }
    }

    func get() {
        do {
            for post in try DataBase.shared.connection.run(
                "SELECT _id, id, photo, date, place, text, index_photo, last_updated FROM post WHERE id = ?", [id.uuidString]
            ) {
                self.row_id = post[0] as! Int64
                self.id = UUID(uuidString: post[1] as! String)!
                self.photo = post[2] as! String
                self.date = convertToDate(post[3] as? String)
                self.place = post[4] as? String
                self.text = post[5] as? String
                self.indexPhoto = post[6] as! Int64
                self.lastUpdated = convertToDate(post[7] as? String)
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }
    }

    func delete() {
        do {
            let count = try DataBase.shared.connection.run(Delete("DELETE FROM post WHERE id = ?", [id.uuidString]))
            if count == 0 {
                Logger.log("post not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }
    }
    
    func changeIndex() {
        do {
            let count = try DataBase.shared.connection.run(Update(
                "UPDATE post SET index_photo = ?, last_updated = ? WHERE id = ?",
                [indexPhoto, convertDate(lastUpdated), id.uuidString]
            ))
            if count == 0 {
                Logger.log("post not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("update failed: \(error)")
        }
    }
    
    func changeID() {
        do {
            let count = try DataBase.shared.connection.run(Update(
                "UPDATE post SET id = ? WHERE _id = ?",
                [id.uuidString, row_id]
            ))
            if count == 0 {
                Logger.log("post not found: id (row_id) = \(id) (\(row_id))")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("update failed: \(error)")
        }
    }
    
    private func convertDate(_ date: Date?) -> String? {
        if let date = date {
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    private func convertToDate(_ strDate: String?) -> Date? {
        if let strDate = strDate {
            return dateFormatter.date(from: strDate)
        }
        return nil
    }
}
