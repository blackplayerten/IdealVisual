//
//  Feed.swift
//  IdealVisual
//
//  Created by Alexandra Kurganova on 29.11.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import SQLite

protocol iARDataFeed {
    func create()
    func delete()
}

final class Feed: iARDataFeed {
    let id: Int = 1
    var user: Int
    
    init(user: Int) {
        self.user = user
    }
    
    func create() {
        do {
            try DataBase.shared.connection.run(Insert(
                "INSERT INTO feed (id, user) VALUES (?, ?)",
                [self.id, user]
            ))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("insert failed: \(error)")
        }
    }
    
    func delete() {
        do {
            let count = try DataBase.shared.connection.run(Delete("DELETE FROM feed WHERE id = 1"))
            if count == 0 {
                Logger.log("fed not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }
    }
}
