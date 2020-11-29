//
//  User.swift
//  IdealVisual
//
//  Created by a.kurganova on 02.11.2019.
//  Copyright © 2019 a.kurganova. All rights reserved.
//

import Foundation
import UIKit
import SQLite

final class User {
    var id: Int64?
    var username: String?
    var email: String?
    var token: String?
    var ava: String?
    
    init(id: Int64? = nil, username: String? = nil, email: String? = nil, token: String? = nil, ava: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.token = token
        self.ava = ava
    }
    
    func create() {
        do {
            try DataBase.shared.connection.run(Insert(
                "INSERT INTO user (id, username, email, token, ava) VALUES (?, ?, ?, ?, ?)",
                [self.id, username, email, token, ava]
            ))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("insert failed: \(error)")
        }
    }

    func update() {
        do {
            let count = try DataBase.shared.connection.run(Update(
                "UPDATE user SET username = ?, email = ?, token = ?, ava = ? WHERE id = ?",
                [username, email, token, ava, id]
            ))
            if count == 0 {
                Logger.log("user not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("update failed: \(error)")
        }
    }

    func get() {
        do {
            for user in try DataBase.shared.connection.run(
                "SELECT id, username, email, token, ava FROM user LIMIT 1"
            ) {
                self.id = user[0] as? Int64
                self.username = user[1] as? String
                self.email = user[2] as? String
                self.token = user[3] as? String
                self.ava = user[4] as? String
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }
    }

    func delete() {
        do {
            let count = try DataBase.shared.connection.run(Delete("DELETE FROM user WHERE id = ?", [id]))
            if count == 0 {
                Logger.log("user not found: id = \(id)")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            Logger.log("constraint failed: \(message), in \(statement!)")
        } catch let error {
            Logger.log("get failed: \(error)")
        }
    }
}
