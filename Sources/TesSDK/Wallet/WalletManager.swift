//
//  WalletManager.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/21/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit

public struct NewWalletData {
    public let encrypted: Data
    public let mnemonic: String
    
    internal init(mnemonic: String, encrypted: Data) {
        self.mnemonic = mnemonic
        self.encrypted = encrypted
    }
}

public class WalletManager {
    public private(set) var networks: Dictionary<Network, WalletNetworkSupportFactory>
    public let storage: WalletStorageProtocol
    
    public init(networks: [WalletNetworkSupportFactory], storage: WalletStorageProtocol) {
        let tuple = networks.map { ($0.network, $0) }
        self.networks = Dictionary(uniqueKeysWithValues: tuple)
        self.storage = storage
    }
    
    public func newWalletData(password: String) throws -> NewWalletData {
        let mnemonic = try Keychain.generateMnemonic()
        return try restoreWalletData(mnemonic: mnemonic, password: password)
    }
    
    public func restoreWalletData(mnemonic: String, password: String) throws -> NewWalletData {
        let data = try Keychain.fromMnemonic(mnemonic: mnemonic, password: password)
        return NewWalletData(mnemonic: mnemonic, encrypted: data.encrypted)
    }
    
    public func create(from data: NewWalletData, password: String) throws -> Wallet {
        let id = UUID().uuidString
        let wallet = try Wallet(id: id, privateData: data.encrypted, networks: networks)
        try wallet.unlock(password: password)
        _ = try wallet.addAccount()
        return wallet
    }
    
    public func has(wallet id: String,  response: @escaping (Bool?, Error?) -> Void) {
        storage.hasWallet(id: id, response: response)
    }
    
    public func load(with id: String, response: @escaping (Wallet?, Error?) -> Void) {
        storage.loadWallet(id: id) { data, err in
            guard let data = data else { response(nil, err); return }
            do {
                try response(Wallet(data: data, networks: self.networks), nil)
            } catch let err {
                response(nil, err)
            }
        }
    }
    
    public func save(wallet: Wallet, response: @escaping (Error?) -> Void) {
        storage.saveWallet(wallet: wallet.storageData, response: response)
    }
    
    public func remove(walletId: String, response: @escaping (Error?) -> Void) {
        storage.removeWallet(id: walletId, response: response)
    }
    
    public func listWalletIds(offset: Int = 0, limit: Int = 10000, response: @escaping ([String], Error?) -> Void) {
        storage.listWalletIds(offset: offset, limit: limit, response: response)
    }
}

extension WalletManager {
    public func load(with id: String) -> Promise<Wallet> {
        return Promise { seal in
            self.load(with: id, response: seal.resolve)
        }
    }
    
    public func save(wallet: Wallet) -> Promise<Void> {
        return Promise { seal in
            self.save(wallet: wallet, response: seal.resolve)
        }
    }
    
    public func remove(walletId: String) -> Promise<Void> {
        return Promise { seal in
            self.remove(walletId: walletId, response: seal.resolve)
        }
    }
    
    public func listWalletIds(offset: Int = 0, limit: Int = 10000) -> Promise<Array<String>> {
        return Promise { seal in
            self.listWalletIds(offset: offset, limit: limit, response: seal.resolve)
        }
    }
}
