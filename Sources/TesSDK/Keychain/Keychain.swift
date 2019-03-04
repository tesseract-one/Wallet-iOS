//
//  Keychain.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Mnemonic

enum KeychainError: Error {
    case wrongPassword
}

class Keychain {
    private static let factories: Array<HDWalletKeyFactory> = [EthereumHDWalletKeyFactory()]
    
    private let storage: StorageProtocol
    
    private var factories: Array<HDWalletKeyFactory> {
        return Keychain.factories
    }
    
    init(storage: StorageProtocol) {
        self.storage = storage
    }
    
    func hasWallet(name: String) -> Promise<Bool> {
        return storage.hasData(key: name)
    }
    
    func loadWallet(name: String, password: String) -> Promise<HDWallet> {
        return _loadWalletData(name: name, password: password)
            .map { try HDWallet(name: name, data: $0, factories: self.factories) }
    }
    
    static func newWalletData(name: String) -> Promise<NewWalletData> {
        let factories = self.factories
        return Promise().map {
            let mnemonic = Mnemonic(language: .english)
            let keys = try HDWallet.keysFromMnemonic(mnemonic: mnemonic, factories: factories)
            return NewWalletData(name: name, mnemonic: mnemonic.toString(), keys: keys)
        }
    }
    
    static func restoreWalletData(name: String, mnemonic: String) -> Promise<NewWalletData> {
        let factories = self.factories
        return Promise().map {
            let mnemonic = Mnemonic(phrase: mnemonic, language: .english)
            let keys = try HDWallet.keysFromMnemonic(mnemonic: mnemonic, factories: factories)
            return NewWalletData(name: name, mnemonic: mnemonic.toString(), keys: keys)
        }
    }
    
    func saveWalletData(data: NewWalletData, password: String) -> Promise<HDWallet> {
        let factories = self.factories
        return Promise.value(data.walletData).then { v1 in
            self.storage
                .saveData(key: data.name, data: try WalletVersionedData(v1: v1).toData())
                .map { v1 }
        }
        .map { try HDWallet(name: data.name, data: $0, factories: factories) }
    }
    
    func renameWallet(name: String, to: String, password: String) -> Promise<HDWallet> {
        return _loadWalletData(name: name, password: password)
            .then { v1 in
                self.storage.saveData(key: to, data: try WalletVersionedData(v1: v1).toData()).map { v1 }
            }
            .map { try HDWallet(name: name, data: $0, factories: self.factories) }
    }
    
    func removeWallet(name: String) -> Promise<Void> {
        return self.storage.removeData(key: name)
    }
    
    private func _loadWalletData(name: String, password: String) -> Promise<WalletDataV1> {
        return storage.loadData(key: name)
            .map { try WalletVersionedData.from(data: $0).walletData() }
    }
}
