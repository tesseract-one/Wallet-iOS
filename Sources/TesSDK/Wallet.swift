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

enum AccountError: Error {
    case addressAndWalletIsNil
    case walletIsNil
}

public class Account {
    public let index: UInt32
    public private(set) var address: String
    
    private var hdWallet: HDWallet? = nil
    
    init(index: UInt32, address: String? = nil, hdWallet: HDWallet? = nil) throws {
        guard address != nil || hdWallet != nil else {
            throw AccountError.addressAndWalletIsNil
        }
        
        self.index = index
        self.address = address ?? ""
        
        try setHdWallet(wallet: hdWallet)
    }
    
    fileprivate func setHdWallet(wallet: HDWallet?) throws {
        if let wallet = wallet {
            address = try wallet.address(network: .Ethereum, path: keyPath)
        }
        hdWallet = wallet
    }
}

extension Account {
    struct StorageData: Codable {
        let index: UInt32
        let address: String
    }
    
    convenience init(storageData: StorageData) throws {
        try self.init(index: storageData.index, address: storageData.address)
    }
    
    var storageData: StorageData {
        return StorageData(index: index, address: address)
    }
}

extension Account {
    var keyPath: EthereumKeyPath {
        return EthereumKeyPath(account: index)
    }
    
    func eth_signTx(tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        //TODO: Rewrite this SHIT to secure methods
        return eth_wallet()
            .map { try $0.privateKey(network: .Ethereum, keyPath: self.keyPath) }
            .map { try EthereumPrivateKey(bytes: $0) }
            .map { try tx.sign(with: $0, chainId: chainId) }
    }
    
    func eth_verify(data: Data, signature: Data) -> Promise<Bool> {
        return eth_wallet()
            .map { try $0.verify(network: .Ethereum, data: data, signature: signature, path: self.keyPath) }
    }
    
    func eth_signData(data: Data) -> Promise<String> {
        return eth_wallet()
            .map {
                var signData = "\u{19}Ethereum Signed Message:\n".data(using: .utf8)!
                signData.append(String(describing: data.count).data(using: .utf8)!)
                signData.append(data)
                let signature = try $0.sign(network: .Ethereum, data: signData, path: self.keyPath)
                return signature.reduce("0x") {$0 + String(format: "%02x", $1)}
        }
    }
    
    private func eth_wallet() -> Promise<HDWallet> {
        return hdWallet != nil ? Promise.value(hdWallet!) : Promise(error: AccountError.walletIsNil)
    }
}

public class Wallet {
    static let walletPublicDataPrefix = "PUBLIC_DATA__"
    static let walletPrefix = "PRIVATE_DATA__"
    
    private let storage: StorageProtocol
    private let keychain: Keychain
    
    private var name: String
    private var hdWallet: HDWallet?
    
    private let accountsLock: NSLock = NSLock()
    
    public private(set) var accounts: Array<Account>
    
    private init(name: String, storage: StorageProtocol, keychain: Keychain, accounts: Array<Account> = [], hdWallet: HDWallet? = nil) {
        self.storage = storage
        self.hdWallet = hdWallet
        self.keychain = keychain
        self.name = name
        self.accounts = accounts
    }
    
    public static func hasWallet(name: String, storage: StorageProtocol) -> Promise<Bool> {
        return storage.hasData(key: Wallet.walletPrefix + name)
    }
    
    public static func newWallet(name: String, password: String, storage: StorageProtocol) -> Promise<(mnemonic: String, wallet: Wallet)> {
        let keychain = Keychain(storage: storage)
        return keychain.createWallet(name: Wallet.walletPrefix + name, password: password)
            .map {
                let wallet = Wallet(name: name, storage: storage, keychain: keychain, hdWallet: $0.wallet)
                let _ = try wallet.addAccount()
                return (mnemonic: $0.mnemonic, wallet: wallet)
            }
            .then { (mnemonic: String, wallet: Wallet) in wallet.save().map { (mnemonic: mnemonic, wallet: wallet) } }
    }
    
    public static func restoreWallet(name: String, mnemonic: String, password: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return keychain.restoreWallet(name: Wallet.walletPrefix + name, mnemonic: mnemonic, password: password)
            .map { Wallet(name: name, storage: storage, keychain: keychain, hdWallet: $0) }
            .then { wallet in wallet.save().map { wallet } }
    }
    
    public static func loadWallet(name: String, storage: StorageProtocol) -> Promise<Wallet> {
        let keychain = Keychain(storage: storage)
        return storage
            .loadData(key: Wallet.walletPublicDataPrefix + name)
            .map { try JSONDecoder().decode(StorageData.self, from: $0) }
            .map { try Wallet(name: name, data: $0, storage: storage, keychain: keychain) }
    }
    
    public var isLocked: Bool {
        return hdWallet == nil
    }
    
    public func unlock(password: String) -> Promise<Void> {
        return keychain.loadWallet(name: Wallet.walletPrefix + name, password: password)
            .done {
                try self.setHdWallet(wallet: $0)
            }
    }
    
    public func addAccount() throws -> Account {
        accountsLock.lock()
        defer { accountsLock.unlock() }
        let account = try Account(index: UInt32(accounts.count), hdWallet: hdWallet)
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
        hdWallet = wallet
        if let wallet = wallet {
            accountsLock.lock()
            defer { accountsLock.unlock() }
            for acc in accounts {
                try acc.setHdWallet(wallet: wallet)
            }
        }
    }
}

extension Wallet {
    struct StorageData: Codable {
        let accounts: Array<Account.StorageData>
    }
    
    fileprivate convenience init(name: String, data: StorageData, storage: StorageProtocol, keychain: Keychain) throws {
        let accounts = try data.accounts.map { try Account(storageData: $0) }
        self.init(name: name, storage: storage, keychain: keychain, accounts: accounts)
    }
    
    var storageData: StorageData {
        accountsLock.lock()
        defer { accountsLock.unlock() }
        return StorageData(accounts: accounts.map { $0.storageData })
    }
}


extension Wallet: EthereumSignProvider {
    public var networks: Array<Network> {
        return [.Ethereum]
    }
    
    public func eth_accounts() -> Promise<Array<String>> {
        return Promise().map { self.accounts.map { $0.address } }
    }
    
    public func eth_signTx(account: String, tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction> {
        return eth_account(address: account)
            .then { $0.eth_signTx(tx: tx, chainId: chainId) }
    }
    
    public func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool> {
        return eth_account(address: account)
            .then { $0.eth_verify(data: data, signature: signature) }
    }
    
    public func eth_signData(account: String, data: Data) -> Promise<String> {
        return eth_account(address: account)
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
