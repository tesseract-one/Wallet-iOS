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
        case walletIsEmpty
    }
    
    private let bag = DisposeBag()
    private let storage: StorageProtocol = UserDefaults(suiteName: "group.io.gettes.wallet.shared")!
    private static let WALLET_KEY = "WALLET"
    
    var wallet: Property<WalletState>!
    var activeAccount: Property<Account?>!
  
    var errorNode: SafePublishSubject<AnyError>!
    
    init() {
        Wallet.addNetworkSupport(lib: EthereumWalletNetwork())
    }
    
    func bootstrap() {
        wallet!.map { $0.exists != nil ? $0.exists!.accounts[0] : nil }.bind(to: activeAccount).dispose(in: bag)
    }
    
    func loadWallet() -> Promise<Wallet?> {
        let promise = Wallet.hasWallet(name: WalletService.WALLET_KEY, storage: storage)
            .then {
                $0 ? Wallet.loadWallet(name: WalletService.WALLET_KEY, storage: self.storage).map { .locked($0) }
                    : Promise<WalletState>.value(.notExist)
            }
        promise.signal
            .executeIn(.immediateOnMain)
            .suppressedErrors
            .bind(to: wallet)
        return promise.map { $0.exists }
    }
    
    func unlockWallet(password: String) -> Promise<Void> {
        guard let wallet = self.wallet.value.exists else {
            return Promise(error: Error.walletIsEmpty)
        }
        return wallet.unlock(password: password)
            .done { [weak self] in
                self?.wallet.next(.unlocked(wallet))
        }
    }
    
    func checkPassword(password: String) -> Promise<Void> {
        guard let wallet = self.wallet.value.exists else {
            return Promise(error: Error.walletIsEmpty)
        }
        return wallet.checkPassword(password: password)
    }
    
    func createWalletData() -> Promise<NewWalletData> {
        return Wallet.newWalletData()
    }
    
    func restoreWalletData(mnemonic: String) -> Promise<NewWalletData> {
        return Wallet.restoreWalletData(mnemonic: mnemonic)
    }
    
    func saveWalletData(data: NewWalletData, password: String) -> Promise<Wallet> {
        return Wallet.saveWalletData(name:WalletService.WALLET_KEY, data: data, password: password, storage: storage)
            .then { wallet -> Promise<Wallet> in
                wallet.accounts[0].associatedData[.name] = "Main Account"
                wallet.accounts[0].associatedData[.emoji] = "\u{1F9B9}"
                return wallet.save().map { wallet }
            }
    }
    
    func saveWallet() -> Promise<Void> {
        guard let wallet = self.wallet.value.exists else {
            return Promise(error: Error.walletIsEmpty)
        }
        return wallet.save()
    }
    
    func setWallet(wallet: Wallet) {
        self.wallet.next(wallet.isLocked ? .locked(wallet) : .unlocked(wallet))
    }
}
