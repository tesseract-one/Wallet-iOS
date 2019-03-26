//
//  DatabaseWalletStorageMigrations.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import SQLite
import SQLiteMigrationManager

private struct InitialMigration: Migration {
    let version: Int64 = 2019_03_25_15_43_00
    
    private let walletTable = Table("Wallet")
    private let accountTable = Table("Account")
    
    private func createWallet(db: Connection) throws {
        try db.run(walletTable.create { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(Expression<Blob>("keys"))
            t.column(Expression<String>("data"))
        })
    }
    
    private func createAccount(db: Connection) throws {
        let index = Expression<Int64>("index")
        try db.run(accountTable.create { t in
            t.column(Expression<String>("id"), primaryKey: true)
            t.column(index)
            t.column(Expression<String>("data"))
            t.column(Expression<String>("walletId"))
            
            t.foreignKey(Expression<String>("walletId"), references: walletTable, Expression<String>("id"), delete: .cascade)
        })
        try db.run(accountTable.createIndex(index))
    }
    
    private func createAddress(db: Connection) throws {
        let network = Expression<Network>("network")
        let table = Table("Address")
        try db.run(table.create { t in
            t.column(Expression<Int64>("index"), primaryKey: true)
            t.column(network)
            t.column(Expression<Blob>("address"))
            t.column(Expression<String>("accountId"))
            
            t.foreignKey(Expression<String>("accountId"), references: accountTable, Expression<String>("id"), delete: .cascade)
        })
        try db.run(table.createIndex(network))
    }
    
    func migrateDatabase(_ db: Connection) throws {
        try createWallet(db: db)
        try createAccount(db: db)
        try createAddress(db: db)
    }
}

struct DatabaseWalletStorageMigrations {
    static let migrations: [Migration] = [
        InitialMigration()
    ]
    private let manager: SQLiteMigrationManager
    
    init(db: Connection) {
        manager = SQLiteMigrationManager(
            db: db,
            migrations: DatabaseWalletStorageMigrations.migrations,
            bundle: nil
        )
    }
    
    func migrate() throws {
        if !manager.hasMigrationsTable() {
            try manager.createMigrationsTable()
        }
        if manager.needsMigration() {
            try manager.migrateDatabase()
        }
    }
}
