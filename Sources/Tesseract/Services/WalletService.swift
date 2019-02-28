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

class WalletService {
    private let bag = DisposeBag()
    private let storage: StorageProtocol = UserDefaults.standard
    private static let WALLET_KEY = "WALLET"
    
    var wallet: Property<Wallet?>!
    let isWalletLocked: Property<Bool> = Property(true)
    
    var errorNode: SafePublishSubject<AnyError>!
    
    func bootstrap() {
        wallet.map { $0 == nil || $0!.isLocked }.bind(to: isWalletLocked).dispose(in: bag)
    }
    
    func loadWallet() -> Promise<Void> {
        let promise = Wallet.hasWallet(name: WalletService.WALLET_KEY, storage: storage)
            .then {
                $0 ? Wallet.loadWallet(name: WalletService.WALLET_KEY, storage: self.storage).map { $0 as Wallet? }
                    : Promise<Wallet?>.value(nil)
            }
        promise.signal
            .suppressAndFeedError(into: errorNode)
            .bind(to: wallet)
        return promise.asVoid()
    }
    
    func unlockWallet(password: String) -> Promise<Void> {
        return wallet.value!.unlock(password: password)
            .done { [weak self] in
                self?.isWalletLocked.next(false)
        }
    }
}
