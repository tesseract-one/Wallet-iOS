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

class WalletService {
    private let bag = DisposeBag()
    private let storage: StorageProtocol = UserDefaults(suiteName: "group.io.gettes.wallet.shared")!
    private static let WALLET_KEY = "WALLET"
    
    var wallet: Property<Wallet?>!
    var activeAccount: Property<TesSDK.Account?>!
  
    let isWalletLocked: Property<Bool> = Property(true)
    
    var errorNode: SafePublishSubject<AnyError>!
    
    init() {
        Wallet.initialize()
        Wallet.addNetworkSupport(lib: EthereumWalletNetwork())
    }
    
    func bootstrap() {
        wallet.map {
          $0 == nil || $0!.isLocked
        }.executeIn(.main).bind(to: isWalletLocked).dispose(in: bag)
        isWalletLocked.with(latestFrom: wallet).map { isLocked, wallet in
          isLocked ? nil : wallet!.accounts[0]
        }.bind(to: activeAccount).dispose(in: bag)
    }
    
    func loadWallet() -> Promise<Wallet?> {
        let promise = Wallet.hasWallet(name: WalletService.WALLET_KEY, storage: storage)
            .then {
                $0 ? Wallet.loadWallet(name: WalletService.WALLET_KEY, storage: self.storage).map { $0 as Wallet? }
                    : Promise<Wallet?>.value(nil)
            }
        promise.signal
            .executeIn(.immediateOnMain)
            .suppressedErrors
            .bind(to: wallet)
        return promise
    }
    
    func unlockWallet(password: String) -> Promise<Void> {
        return wallet.value!.unlock(password: password)
            .done { [weak self] in
                self?.isWalletLocked.next(false)
        }
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
                wallet.accounts[0].associatedData[.name] = "Main Account".serialized
                wallet.accounts[0].associatedData[.emoji] = "\u{1F9B9}".serialized
                return wallet.save().map { wallet }
            }
    }
    
    func saveWallet() -> Promise<Void> {
        return wallet.value!.save()
    }
    
    func setWallet(wallet: Wallet) {
        self.wallet.next(wallet)
    }
}
