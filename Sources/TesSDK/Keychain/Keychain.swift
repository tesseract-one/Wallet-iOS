//
//  Keychain.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import CKMnemonic

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
    
    static func newWalletData() -> Promise<NewWalletData> {
        let factories = self.factories
        return Promise().map {
            let mnemonic = try CKMnemonic.generateMnemonic(strength: 128, language: .english)
            let keys = try HDWallet.keysFromMnemonic(mnemonic: mnemonic, factories: factories)
            return NewWalletData(mnemonic: mnemonic, keys: keys)
        }
    }
    
    static func restoreWalletData(mnemonic: String) -> Promise<NewWalletData> {
        let factories = self.factories
        return Promise().map {
            let keys = try HDWallet.keysFromMnemonic(mnemonic: mnemonic, factories: factories)
            return NewWalletData(mnemonic: mnemonic, keys: keys)
        }
    }
    
    func saveWalletData(name: String, data: NewWalletData, password: String) -> Promise<HDWallet> {
        let factories = self.factories
        return Promise.value(data.walletData).then { v1 in
            self.storage
                .saveData(key: name, data: try WalletVersionedData(v1: v1).toData())
                .map { v1 }
        }
        .map { try HDWallet(name: name, data: $0, factories: factories) }
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
