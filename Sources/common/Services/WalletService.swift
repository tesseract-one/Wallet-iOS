//
//  WalletService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import TesSDK
import ReactiveKit
import PromiseKit

extension Account.AssociatedKeys {
    static let name = Account.AssociatedKeys(rawValue: "name")
    static let emoji = Account.AssociatedKeys(rawValue: "emoji")
}

enum WalletState: Equatable {
    case empty
    case notExist
    case locked(Wallet)
    case unlocked(Wallet)
    
    var unlocked: Wallet? {
        switch self {
        case .unlocked(let w): return w
        default: return nil
        }
    }
    
    var exists: Wallet? {
        switch self {
        case .unlocked(let w): return w
        case .locked(let w): return w
        default: return nil
        }
    }
    
    var isEmpty: Bool {
        switch self {
        case .empty: return true
        default: return false
        }
    }
}

class WalletService {
    enum Error: Swift.Error {
        case walletIsNotLoaded
        case noStoredWallet
    }
    
    private let bag = DisposeBag()
    
    private var walletManager: WalletManager!
    
    var storage: WalletStorageProtocol!
    
    var wallet: Property<WalletState>!
    var activeAccount: Property<Account?>!
    
    var errorNode: SafePublishSubject<AnyError>!
    
    
    func bootstrap() {
        walletManager = WalletManager(
            networks: [EthereumWalletNetwork()],
            storage: storage
        )
        
        wallet!.map { $0.exists != nil ? $0.exists!.accounts[0] : nil }.bind(to: activeAccount).dispose(in: bag)
    }
    
    func loadWallet() -> Promise<Wallet?> {
        let promise = walletManager
            .listWalletIds()
            .then { ids -> Promise<WalletState> in
                guard ids.count > 0 else { throw Error.noStoredWallet }
                return self.walletManager.load(with: ids[0]).map{.locked($0)}
            }
            .recover { err -> Promise<WalletState> in
                if case WalletStorageError.noData(_) = err {
                    return Promise.value(.notExist)
                }
                if case Error.noStoredWallet = err {
                    return Promise.value(.notExist)
                }
                throw err
            }
        
        promise.signal
            .executeIn(.immediateOnMain)
            .suppressedErrors
            .bind(to: wallet)
        return promise.map { $0.exists }
    }
    
    func checkPassword(password: String) throws -> Bool {
        guard let wallet = wallet.value.exists else {
            throw Error.walletIsNotLoaded
        }
        return wallet.checkPassword(password: password)
    }
    
    func unlockWallet(password: String) throws {
        guard let wallet = wallet.value.exists else {
            throw Error.walletIsNotLoaded
        }
        try wallet.unlock(password: password)
        setWallet(wallet: wallet)
    }
    
    func newAccount(name: String, emoji: String) -> Promise<Account> {
        guard let wallet = wallet.value.exists else {
            return Promise(error: Error.walletIsNotLoaded)
        }
        return Promise()
            .map {
                let account = try wallet.addAccount()
                account.associatedData[.name] = name
                account.associatedData[.emoji] = emoji
                return account
            }
            .then { acc in self.walletManager.save(wallet: wallet).map{ acc } }
    }
    
    func createWalletData(password: String) throws -> NewWalletData {
        return try walletManager.newWalletData(password: password)
    }
    
    func restoreWalletData(mnemonic: String, password: String) throws -> NewWalletData {
        return try walletManager.restoreWalletData(mnemonic: mnemonic, password: password)
    }
    
    func newWallet(data: NewWalletData, password: String, isMetamask: Bool) -> Promise<Wallet> {
        return walletManager.listWalletIds()
            .map { ids -> (Wallet, Array<String>) in
                let wallet = try self.walletManager.create(from: data, password: password)
                wallet.accounts[0].associatedData[.name] = "Main Account"
                wallet.accounts[0].associatedData[.emoji] = "\u{1F9B9}"
                wallet.associatedData[.isMetamask] = isMetamask
                return (wallet, ids)
            }
            .then { wallet, ids in
                self.walletManager.save(wallet: wallet).map { (wallet, ids) }
            }
            .then { wallet, ids in // We have only one wallet in app. Remove old.
                when(fulfilled: ids.map{self.walletManager.remove(walletId: $0)})
                    .map { wallet }
            }
    }
    
    func saveWallet() -> Promise<Void> {
        guard let wallet = wallet.value.exists else {
            return Promise(error: Error.walletIsNotLoaded)
        }
        return walletManager.save(wallet: wallet)
    }
    
    func setWallet(wallet: Wallet) {
        self.wallet.next(wallet.isLocked ? .locked(wallet) : .unlocked(wallet))
    }
}
