//
//  WalletService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import PromiseKit
import Wallet
import Bond

class WalletService {
    enum Error: Swift.Error {
        case walletIsNotInitialized
        case noStoredWallet
    }

    private let bag = DisposeBag()
    
    private var walletManager: Manager!
    
    var storage: StorageProtocol!
    
    var web3Service: EthereumWeb3Service!
    
    var network: Property<UInt64>!
    var wallet: Property<WalletViewModel?>!
    var activeAccount: Property<AccountViewModel?>!
    
    var errorNode: PassthroughSubject<Swift.Error, Never>!
    
    var settings: Settings!
    
    private var updateTimer: Timer? = nil
    
    func bootstrap() {
        walletManager = try! Manager(
            networks: [EthereumNetwork()],
            storage: storage
        )
        
        let settings = self.settings!
        
        wallet
            .map { wallet -> AccountViewModel? in
                guard let wallet = wallet else {
                    return nil
                }
                
                guard let activeAccountId = settings.string(forKey: .activeAccountId) else {
                    settings.set(wallet.accounts[0].id, forKey: .activeAccountId)
                    return wallet.accounts[0]
                }
                
                return wallet.accounts.collection.first { $0.id == activeAccountId } ?? wallet.accounts[0]
            }
            .bind(to: activeAccount)
            .dispose(in: bag)
        
        activeAccount.filter { $0 != nil }
            .observeNext { account in
                settings.set(account!.id, forKey: .activeAccountId)
            }.dispose(in: bag)
        
        wallet.observeIn(.main)
            .flatMapLatest{ wallet in
                wallet?.accounts.map { _ in wallet } ?? Signal(just: nil)
            }
            .with(weak: self)
            .observeNext { wallet, sself in
                sself.checkTimer(wallet: wallet)
            }.dispose(in: bag)
        
        network.observeIn(.main)
            .with(weak: self)
            .observeNext { _, sself in
                sself.updateBalance()
            }.dispose(in: bag)
    }
    
    func loadWallet() -> Promise<WalletViewModel?> {
        let promise = walletManager
            .listWalletIds()
            .then { ids -> Promise<WalletViewModel?> in
                guard ids.count > 0 else { throw Error.noStoredWallet }
                return self.walletManager.load(with: ids[0]).map{ WalletViewModel(wallet: $0) }
            }
            .recover { err -> Promise<WalletViewModel?> in
                if case StorageError.noData(_) = err {
                    return Promise.value(nil)
                }
                if case Error.noStoredWallet = err {
                    return Promise.value(nil)
                }
                throw err
            }
        
        return promise.get(on: .main) { [weak self] wallet in
            self?.wallet.send(wallet)
        }
    }
    
    func checkPassword(password: String) throws -> Bool {
        guard let wallet = wallet.value else {
            throw Error.walletIsNotInitialized
        }
        return wallet.checkPassword(password: password)
    }
    
    func unlockWallet(password: String) throws {
        guard let wallet = wallet.value else {
            throw Error.walletIsNotInitialized
        }
        try wallet.unlock(password: password)
    }
    
    func newAccount(name: String, emoji: String) -> Promise<AccountViewModel> {
        guard let wallet = wallet.value else {
            return Promise(error: Error.walletIsNotInitialized)
        }
        return Promise()
            .map {
                try wallet.addAccount(emoji: emoji, name: name)
            }
            .then { acc in self.walletManager.save(wallet: wallet.wallet).map{ acc } }
    }
    
    func createWalletData(password: String) throws -> NewWalletData {
        return try walletManager.newWalletData(password: password)
    }
    
    func restoreWalletData(mnemonic: String, password: String) throws -> NewWalletData {
        return try walletManager.restoreWalletData(mnemonic: mnemonic, password: password)
    }
    
    func newWallet(data: NewWalletData, password: String, isMetamask: Bool) -> Promise<WalletViewModel> {
        return walletManager.listWalletIds()
            .map { ids -> (Wallet, Array<String>) in
                let wallet = try self.walletManager.create(from: data)
                wallet.associatedData[.isMetamask] = isMetamask.serializable
                
                try wallet.unlock(password: password)
                
                let account = try wallet.addAccount()
                account.associatedData[.name] = "Main Account".serializable
                account.associatedData[.emoji] = "\u{1F9B9}".serializable
                
                return (wallet, ids)
            }
            .then { wallet, ids in
                self.walletManager.save(wallet: wallet).map { (wallet, ids) }
            }
            .then { wallet, ids in // We have only one wallet in app. Remove old.
                when(fulfilled: ids.map{self.walletManager.remove(walletId: $0)})
                    .map { WalletViewModel(wallet: wallet) }
            }
    }
    
    func saveWallet() -> Promise<Void> {
        guard let wallet = wallet.value else {
            return Promise(error: Error.walletIsNotInitialized)
        }
        return walletManager.save(wallet: wallet.wallet)
    }
    
    func setWallet(wallet: WalletViewModel) {
        self.wallet.send(wallet)
    }
    
    public func updateBalance() {
        guard let accounts = wallet.value?.accounts else { return }
        let network = self.network.value
        for account in accounts.collection {
            web3Service.getBalance(accountId: account.id, networkId: network)
                .done(on: .main) { balance in
                    account.updateBalance(balance: balance)
                }.catch(on: .main) { _ in
                    account.updateBalance(balance: nil)
                }
        }
    }
    
    private func checkTimer(wallet: WalletViewModel?) {
        if let _ = wallet {
            if updateTimer == nil {
                updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
                    self?.updateBalance()
                }
            }
            updateBalance()
        } else {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
}
