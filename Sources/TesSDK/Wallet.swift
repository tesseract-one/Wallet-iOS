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

class Account {
    let index: UInt32
    let address: String
    
    fileprivate let hdWallet: HDWallet
    
    init(index: UInt32, hdWallet: HDWallet) throws {
        self.index = index
        self.hdWallet = hdWallet
        self.address = try hdWallet.address(network: .Ethereum, path: EthereumKeyPath(account: index))
    }
}

extension Account {
    struct StorageData: Codable {
        let index: UInt32
    }
    
    convenience init(storageData: StorageData, hdWallet: HDWallet) throws {
        try self.init(index: storageData.index, hdWallet: hdWallet)
    }
    
    var storageData: StorageData {
        return StorageData(index: index)
    }
}

extension Account {
    var keyPath: EthereumKeyPath {
        return EthereumKeyPath(account: index)
    }
    
    func eth_signTx(tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        //TODO: Rewrite this SHIT to secure methods
        return Promise()
            .map { try self.hdWallet.privateKey(network: .Ethereum, keyPath: self.keyPath) }
            .map { try EthereumPrivateKey(bytes: $0) }
            .map { try tx.sign(with: $0, chainId: chainId) }
    }
    
    func eth_verify(data: Data, signature: Data) -> Promise<Bool> {
        return Promise()
            .map { try self.hdWallet.verify(network: .Ethereum, data: data, signature: signature, path: self.keyPath) }
    }
    
    func eth_signData(data: Data) -> Promise<String> {
        return Promise()
            .map {
                var signData = "\u{19}Ethereum Signed Message:\n".data(using: .utf8)!
                signData.append(String(describing: data.count).data(using: .utf8)!)
                signData.append(data)
                let signature = try self.hdWallet.sign(network: .Ethereum, data: signData, path: self.keyPath)
                return signature.reduce("0x") {$0 + String(format: "%02x", $1)}
        }
    }
}

class Wallet {
    static let walletPublicDataPrefix = "PUBLIC_DATA__"
    static let walletPrefix = "WALLET__"
    
    let storage: StorageProtocol
    let hdWallet: HDWallet
    let keychain: Keychain
    
    let accountsLock: NSLock = NSLock()
    
    public fileprivate(set) var accounts: Array<Account>
    
    private init(storage: StorageProtocol, hdWallet: HDWallet, keychain: Keychain) {
        self.storage = storage
        self.hdWallet = hdWallet
        self.keychain = keychain
        self.accounts = []
    }
    
    static func hasWallet(name: String, storage: StorageProtocol) -> Promise<Bool> {
        return storage.hasData(key: Wallet.walletPrefix + name)
    }
    
    static func newWallet(name: String, password: String, storage: StorageProtocol) -> Promise<(mnemonic: String, wallet: Wallet)> {
        let keychain = Keychain(storage: storage)
        return keychain.createWallet(name: Wallet.walletPrefix + name, password: password)
            .map {
                let wallet = Wallet(storage: storage, hdWallet: $0.wallet, keychain: keychain)
                let _ = try wallet.addAccount()
                return (mnemonic: $0.mnemonic, wallet: wallet)
            }
            .then { (mnemonic: String, wallet: Wallet) in wallet.save().map { (mnemonic: mnemonic, wallet: wallet) } }
    }
    
    static func restoreWallet(name: String, mnemonic: String, password: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return keychain.restoreWallet(name: Wallet.walletPrefix + name, mnemonic: mnemonic, password: password)
            .map { Wallet(storage: storage, hdWallet: $0, keychain: keychain) }
            .then { wallet in wallet.save().map { wallet } }
    }
    
    static func loadWallet(name: String, password: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return keychain.loadWallet(name: Wallet.walletPrefix + name, password: password)
            .then { wallet in
                storage
                    .loadData(key: Wallet.walletPublicDataPrefix + wallet.name)
                    .map { (wallet, try JSONDecoder().decode(StorageData.self, from: $0)) }
            }
            .map { wallet, data in
                try Wallet(data: data, storage: storage, hdWallet: wallet, keychain: keychain)
            }
    }
    
    func addAccount() throws -> Account {
        accountsLock.lock()
        defer {
            accountsLock.unlock()
        }
        let account = try Account(index: UInt32(accounts.count), hdWallet: hdWallet)
        accounts.append(account)
        return account
    }
    
    func save() -> Promise<Void> {
        let data = storageData
        let storage = self.storage
        let key = Wallet.walletPublicDataPrefix + hdWallet.name
        return Promise()
            .map { try JSONEncoder().encode(data) }
            .then { storage.saveData(key: key, data: $0) }
    }
}

extension Wallet {
    struct StorageData: Codable {
        let accounts: Array<Account.StorageData>
    }
    
    fileprivate convenience init(data: StorageData, storage: StorageProtocol, hdWallet: HDWallet, keychain: Keychain) throws {
        self.init(storage: storage, hdWallet: hdWallet, keychain: keychain)
        self.accounts = try data.accounts.map {
            try Account(storageData: $0, hdWallet: hdWallet)
        }
    }
    
    var storageData: StorageData {
        accountsLock.lock()
        defer {
            accountsLock.unlock()
        }
        return StorageData(accounts: accounts.map { $0.storageData })
    }
}


extension Wallet: EthereumSignProvider {
    var networks: Array<Network> {
        return [.Ethereum]
    }
    
    func eth_accounts() -> Promise<Array<String>> {
        return Promise().map { self.accounts.map { $0.address } }
    }
    
    func eth_signTx(account: String, tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        return self.eth_account(address: account)
            .then { $0.eth_signTx(tx: tx, chainId: chainId) }
    }
    
    func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
        return self.eth_account(address: account)
            .then { $0.eth_verify(data: data, signature: signature) }
    }
    
    func eth_signData(account: String, data: Data) -> Promise<String> {
        return self.eth_account(address: account)
            .then { $0.eth_signData(data: data) }
    }
    
//    func eth_signTypedData(account: String) -> Promise<Array<UInt8>> {
//        <#code#>
//    }
    
    private func eth_account(address: String) -> Promise<Account> {
        let accounts = self.accounts
        return Promise().map {
            let opAccount = accounts.first { $0.address == address }
            guard let account = opAccount else {
                throw EthereumSignProviderError.accountDoesNotExist(address)
            }
            return account
        }
    }
}

extension Wallet {
    var distributedAPI: dAPI {
        let dapi = dAPI()
        dapi.signProvider = self
        return dapi
    }
}
