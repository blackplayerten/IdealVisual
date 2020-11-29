//
//  DBManager.swift
//  IdealVisual
//
//  Created by Alexandra Kurganova on 28.11.2020.
//  Copyright © 2020 a.kurganova. All rights reserved.
//

import Foundation
import SQLite
import SQLiteMigrationManager

final class DataBase {
    static private let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    
    static let shared = DataBase(path: "\(path)/db.sqlite3")!
    let connection: Connection
    
    init?(path: String) {
        do {
            Logger.log("path: \(path)")
            connection = try Connection(path)
            
            let migrationManager = SQLiteMigrationManager(db: self.connection,
                                                          migrations: [UserMigration(), FeedMigration(), PostMigration()])
            
            if !migrationManager.hasMigrationsTable() {
                try migrationManager.createMigrationsTable()
            }
            
            if migrationManager.needsMigration() {
                try migrationManager.migrateDatabase()
            }
        } catch let error {
            Logger.log(error)
            return nil
        }
    }
}

final class UserMigration: Migration {
    var version: Int64 = 2020_11_28_17_50_00
    
    func migrateDatabase(_ db: Connection) throws {
        try db.run(
            """
            CREATE TABLE user (
                id INT PRIMARY KEY NOT NULL,
                username CHAR(64) NOT NULL,
                email CHAR(64) NOT NULL,
                token CHAR(36) NOT NULL,
                ava CHAR(128)
            )
            """
        )
    }
}

final class FeedMigration: Migration {
    var version: Int64 = 2020_11_28_17_51_00
    
    func migrateDatabase(_ db: Connection) throws {
        try db.run(
            """
            CREATE TABLE feed (
                id INT PRIMARY KEY NOT NULL,
                user INT NOT NULL,
                FOREIGN KEY (user) REFERENCES user(id)
            )
            """
        )
    }
}

final class PostMigration: Migration {
    var version: Int64 = 2020_11_28_17_52_00
    
    func migrateDatabase(_ db: Connection) throws {
        try db.run(
            """
            CREATE TABLE post (
                id CHAR(36) PRIMARY KEY NOT NULL,
                feed INT NOT NULL,
                photo CHAR(128) NOT NULL,
                date CHAR(30) NOT NULL,
                place CHAR(36) NOT NULL,
                text CHAR(36) NOT NULL,
                index_photo INT NOT NULL,
                last_updated CHAR(30) NOT NULL DEFAULT now,
                FOREIGN KEY (feed) REFERENCES feed(id)
            )
            """
        )
    }
}
