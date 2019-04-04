//
//  Context.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Wallet

enum ExtensionErrors: Error {
    case walletIsEmpty
}

class ExtensionContext {
    let wallet = Property<WalletViewModel?>(nil)
    let activeAccount = Property<Account?>(nil)
    
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service()
    let changeRateService = ChangeRateService()
    let passwordService = KeychainPasswordService()
    
    let errors = SafePublishSubject<Swift.Error>()
    
    let settings: Settings = UserDefaults(suiteName: SHARED_GROUP)!
    
    let walletIsLoaded = SafePublishSubject<Bool>()
    
    func bootstrap() {
        let storage = try! DatabaseWalletStorage(path: storagePath)
        
        walletService.errorNode = errors
        walletService.wallet = wallet
        walletService.activeAccount = activeAccount
        walletService.storage = storage
        walletService.settings = settings
        
        ethereumWeb3Service.wallet = wallet
        
        try! storage.bootstrap()
        walletService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRateService.bootstrap()
        passwordService.bootstrap()
        
        walletService
            .loadWallet()
            .done { wallet in
                self.walletIsLoaded.next(wallet != nil)
            }
            .catch {
                self.errors.next($0)
            }
    }
    
    private var storagePath: String {
        let sharedDir = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SHARED_GROUP
            )!
        return sharedDir.appendingPathComponent(DATABASE_NAME).absoluteString
    }
}
