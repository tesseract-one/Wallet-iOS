//
//  DatabaseWalletStorage.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import SQLite

extension Network: Value {
    public typealias Datatype = Int64
    
    public static var declaredDatatype: String {
        return Int64.declaredDatatype
    }
    
    public static func fromDatatypeValue(_ datatypeValue: Int64) -> Network {
        return Network(rawValue: UInt32(datatypeValue))
    }
    
    public var datatypeValue: Int64 {
        return Int64(self.rawValue)
    }
}

public class DatabaseWalletStorage {
    private let db: Connection
    private let queue: DispatchQueue
    
    public init(path: String) throws {
        db = try Connection(path)
        queue = DispatchQueue(label: "wallet database queue")
    }
    
    public func bootstrap() throws {
        try DatabaseWalletStorageMigrations(db: db).migrate()
    }
    
    private func getAddresses(accountId: String) throws -> [Network: [Address]] {
        let query = AddressDBModel.table.filter(AddressDBModel.accountId == accountId)
        var addresses = Dictionary<Network, Array<Address>>()
        for row in try db.prepare(query) {
            let address = try AddressDBModel(row: row).toAddress()
            var arr = addresses[address.network] ?? []
            arr.append(address)
            addresses[address.network] = arr
        }
        return addresses
    }
}

extension DatabaseWalletStorage: WalletStorageProtocol {
    public func listWalletIds(offset: Int = 0, limit: Int = 1000, response: @escaping ([String], Error?) -> Void) {
        queue.async {
            let query = WalletDBModel.table
                .select(WalletDBModel.id)
                .limit(limit, offset: offset)
            do {
                let data = try Array(self.db.prepare(query)).map{try $0.get(WalletDBModel.id)}
                response(data, nil)
            } catch let err {
                response([], err)
            }
        }
    }
    
    public func hasWallet(id: String, response: @escaping (Bool?, Error?) -> Void) {
        queue.async {
            let query = WalletDBModel.table.filter(WalletDBModel.id == id).count
            do {
                response(try self.db.scalar(query) == 1, nil)
            } catch let err {
                response(nil, err)
            }
        }
    }
    
    public func loadWallet(id: String, response: @escaping (Wallet.StorageData?, Error?) -> Void) {
        queue.async {
            let dbWallet: WalletDBModel
            do {
                if let row = try self.db.pluck(WalletDBModel.table.filter(WalletDBModel.id == id)) {
                    dbWallet = WalletDBModel(row: row)
                } else {
                    response(nil, WalletStorageError.noData(forKey: id))
                    return
                }
            } catch let err {
                response(nil, err)
                return
            }
            let dbAccounts: [AccountDBModel]
            do {
                let query = AccountDBModel.table.filter(AccountDBModel.walletId == id)
                dbAccounts = Array(try self.db.prepare(query)).map{AccountDBModel(row: $0)}
            } catch let err {
                response(nil, err)
                return
            }
            var accounts: Array<Account.StorageData> = []
            do {
                for account in dbAccounts {
                    let addresses = try self.getAddresses(accountId: account.getId())
                    accounts.append(try account.toAccountStorage(addresses: addresses))
                }
                let wallet = try dbWallet.toWalletStorage(accounts: accounts)
                response(wallet, nil)
            } catch let err{
                response(nil, err)
            }
        }
    }
    
    public func saveWallet(wallet: Wallet.StorageData, response: @escaping (Error?) -> Void) {
        queue.async {
            do {
                try self.db.run(
                    WalletDBModel.table.insert(
                        or: .replace,
                        WalletDBModel.setters(storage: wallet)
                    )
                )
                let walletId = wallet.id
                for account in wallet.accounts {
                    try self.db.run(
                        AccountDBModel.table.insert(
                            or: .replace,
                            AccountDBModel.setters(storage: account, walletId: walletId)
                        )
                    )
                    let accountId = account.id
                    for addresses in account.addresses.values {
                        for address in addresses {
                            try self.db.run(
                                AddressDBModel.table.insert(
                                    or: .replace,
                                    AddressDBModel.setters(
                                        storage: address, accountId: accountId
                                    )
                                )
                            )
                        }
                        
                    }
                }
            } catch let err {
                response(err)
                return
            }
            response(nil)
        }
    }
    
    public func removeWallet(id: String, response: @escaping (Error?) -> Void) {
        queue.async {
            do {
                try self.db.run(WalletDBModel.table.filter(WalletDBModel.id == id).delete())
                response(nil)
            } catch let err {
                response(err)
            }
        }
    }
    
    public func loadTransactions<T>(query: WalletStorageQuery, response: @escaping (Array<T>?, Error?) -> Void) where T : SerializableValueDecodable {
        fatalError("Not implemented")
    }
    
    public func saveTransactions<T>(transactions: Array<T>, response: @escaping (Error?) -> Void) where T : SerializableValueEncodable {
        fatalError("Not implemented")
    }
    
    public func loadTokens<T>(query: WalletStorageQuery, response: @escaping (Array<T>?, Error?) -> Void) where T : SerializableValueDecodable {
        fatalError("Not implemented")
    }
    
    public func saveTokens<T>(transactions: Array<T>, response: @escaping (Error?) -> Void) where T : SerializableValueEncodable {
        fatalError("Not implemented")
    }
}
