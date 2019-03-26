//
//  Context.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import TesSDK
import ReactiveKit

enum ExtensionErrors: Error {
    case walletIsEmpty
}

class ExtensionContext {
    let wallet = Property<WalletState>(.empty)
    let activeAccount = Property<Account?>(nil)
    
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service()
    let changeRateService = ChangeRateService()
    let passwordService = KeychainPasswordService()
    
    let errors = SafePublishSubject<AnyError>()
    
    let settings = UserDefaults(suiteName: SHARED_GROUP)!
    
    func bootstrap() {
        let storage = try! DatabaseWalletStorage(path: storagePath)
        
        walletService.errorNode = errors
        walletService.wallet = wallet
        walletService.activeAccount = activeAccount
        walletService.storage = storage
        
        ethereumWeb3Service.wallet = wallet
        
        try! storage.bootstrap()
        walletService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRateService.bootstrap()
        passwordService.bootstrap()
        
        walletService
            .loadWallet()
            .done { wallet in
                if wallet == nil {
                    throw ExtensionErrors.walletIsEmpty
                }
            }
            .signal
            .errorNode
            .bind(to: errors)
    }
    
    private var storagePath: String {
        let sharedDir = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SHARED_GROUP
            )!
        return sharedDir.appendingPathComponent(DATABASE_NAME).absoluteString
    }
}
