//
//  Wallet.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/27/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Web3

public class Wallet: SignProvider {
    private static let walletPublicDataPrefix = "PUBLIC_DATA__"
    private static let walletPrefix = "PRIVATE_DATA__"
    
    public private(set) static var networks: Dictionary<Network, WalletNetworkSupportFactory> = [:]
    
    private let storage: StorageProtocol
    private let keychain: Keychain
    
    private var name: String
    private let accountsLock: NSLock = NSLock()
    
    public private(set) var networkSupport: Dictionary<Network, WalletNetworkSupport>
    
    public private(set) var accounts: Array<Account>
    
    public var networks: Set<Network> {
        return Set(networkSupport.keys)
    }
    
    // TODO: Remove this SHIT. This is really a TEMPORARY solution.
    var password: String!
    
    private init(name: String, storage: StorageProtocol, keychain: Keychain, accounts: Array<Account> = [], hdWallet: HDWallet? = nil) throws {
        self.storage = storage
        self.keychain = keychain
        self.name = name
        self.accounts = accounts
        self.networkSupport = [:]
        
        if let wallet = hdWallet {
            try setHdWallet(wallet: wallet)
        }
    }
    
    public static func addNetworkSupport(lib: WalletNetworkSupportFactory) {
        self.networks[lib.network] = lib
    }
    
    public static func setSupportedNetworks(libs: Array<WalletNetworkSupportFactory>) {
        for lib in libs {
            self.addNetworkSupport(lib: lib)
        }
    }
    
    public static func hasWallet(name: String, storage: StorageProtocol) -> Promise<Bool> {
        return storage.hasData(key: Wallet.walletPrefix + name)
    }
    
    public static func newWalletData() -> Promise<NewWalletData> {
        return Keychain.newWalletData()
    }
    
    public static func restoreWalletData(mnemonic: String) -> Promise<NewWalletData> {
        return Keychain.restoreWalletData(mnemonic:mnemonic)
    }
    
    public static func saveWalletData(name: String, data: NewWalletData, password: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return keychain.saveWalletData(name: Wallet.walletPrefix + name, data: data, password: password)
            .then { (hd) -> Promise<Wallet> in
                let wallet = try Wallet(name: name, storage: storage, keychain: keychain, hdWallet: hd)
                wallet.password = password
                let _ = try wallet.addAccount()
                return wallet.save().map { wallet }
            }
    }
    
    public static func loadWallet(name: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return storage
            .loadData(key: Wallet.walletPublicDataPrefix + name)
            .map { try JSONDecoder().decode(StorageData.self, from: $0) }
            .map { try Wallet(name: name, data: $0, storage: storage, keychain: keychain) }
    }
    
    public var isLocked: Bool {
        return networkSupport.count == 0
    }
    
    public func unlock(password: String) -> Promise<Void> {
        if password != self.password {
            return Promise(error: KeychainError.wrongPassword)
        }
        return keychain.loadWallet(name: Wallet.walletPrefix + name, password: password)
            .done {
                try self.setHdWallet(wallet: $0)
            }
    }
    
    public func checkPassword(password: String) -> Promise<Void> {
        if password != self.password {
            return Promise(error: KeychainError.wrongPassword)
        }
        return Promise.value(())
    }
    
    public func addAccount() throws -> Account {
        accountsLock.lock()
        defer { accountsLock.unlock() }
        let name = "Account \(accounts.count)"
        let account = try Account(index: UInt32(accounts.count), name: name, networkSupport: networkSupport)
        accounts.append(account)
        return account
    }
    
    public func save() -> Promise<Void> {
        let data = storageData
        let storage = self.storage
        let key = Wallet.walletPublicDataPrefix + name
        return Promise()
            .map { try JSONEncoder().encode(data) }
            .then { storage.saveData(key: key, data: $0) }
    }
    
    private func setHdWallet(wallet: HDWallet?) throws {
        accountsLock.lock()
        defer { accountsLock.unlock() }
        if let wallet = wallet {
            for network in wallet.networks {
                if let factory = Wallet.networks[network] {
                    networkSupport[network] = factory.withHdWallet(wallet: wallet)
                }
            }
            for account in accounts {
                try account.setNetworkSupport(supported: networkSupport)
            }
        }
    }
}

extension Wallet {
    struct StorageData: Codable {
        let accounts: Array<Account.StorageData>
        // TEMPORARY KLUDGE
        let password: String
    }
    
    fileprivate convenience init(name: String, data: StorageData, storage: StorageProtocol, keychain: Keychain) throws {
        let accounts = try data.accounts.map { try Account(storageData: $0) }
        try self.init(name: name, storage: storage, keychain: keychain, accounts: accounts)
        password = data.password
    }
    
    var storageData: StorageData {
        accountsLock.lock()
        defer { accountsLock.unlock() }
        return StorageData(accounts: accounts.map { $0.storageData }, password: password)
    }
}

extension Wallet {
    public var distributedAPI: dAPI {
        let dapi = dAPI()
        dapi.signProvider = self
        return dapi
    }
}

extension Wallet: Equatable {
    //TODO: Write proper equatable
    public static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.name == rhs.name
    }
}