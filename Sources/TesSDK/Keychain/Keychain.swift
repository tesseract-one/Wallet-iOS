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
    private let storage: StorageProtocol
    private var factories: Array<HDWalletKeyFactory> = []
    
    init(storage: StorageProtocol) {
        self.storage = storage
        factories.append(EthereumHDWalletKeyFactory())
    }
    
    func hasWallet(name: String) -> Promise<Bool> {
        return storage.hasData(key: name)
    }
    
    func loadWallet(name: String, password: String) -> Promise<HDWallet> {
        return _loadWalletData(name: name, password: password)
            .map { try HDWallet(name: name, data: $0, factories: self.factories) }
    }
    
    func createWallet(name: String, password: String) -> Promise<(mnemonic: String, wallet: HDWallet)> {
        let mnemonic = Mnemonic(language: .english)
        return _newWalletFromMnemonic(name: name, mnemonic: mnemonic)
            .map { (mnemonic: mnemonic.toString(), wallet: $0) }
    }
    
    func restoreWallet(name: String, mnemonic: String, password: String) -> Promise<HDWallet> {
        let mnemonicObj = Mnemonic(phrase: mnemonic, language: .english)
        return _newWalletFromMnemonic(name: name, mnemonic: mnemonicObj)
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
    
    private func _newWalletFromMnemonic(name: String, mnemonic: Mnemonic) -> Promise<HDWallet> {
        do {
            let keys = try HDWallet.keysFromMnemonic(mnemonic: mnemonic, factories: factories)
            let data = try WalletVersionedData(v1: WalletDataV1(keys: keys)).toData()
            return self.storage
                .saveData(key: name, data: data)
                .map { try HDWallet(factories: self.factories, name: name, pkeys: keys) }
        } catch(let err) {
            return Promise(error: err)
        }
    }
    
    private func _loadWalletData(name: String, password: String) -> Promise<WalletDataV1> {
        return storage.loadData(key: name)
            .map { try WalletVersionedData.from(data: $0).walletData() }
    }
}
