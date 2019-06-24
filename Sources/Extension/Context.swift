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

class ExtensionContext: CommonContext {
    let wallet = Property<WalletViewModel?>(nil)
    let activeAccount = Property<AccountViewModel?>(nil)
    
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service()
    let changeRateService = ChangeRateService()
    let passwordService = KeychainPasswordService()
    
    let errorNode = PassthroughSubject<Swift.Error, Never>()
    
    let settings: Settings = UserDefaults(suiteName: SHARED_GROUP)!
    
    let isApplicationLoaded = Property<Bool>(false)
    
    func bootstrap() {
        let storage = try! DatabaseWalletStorage(path: storagePath)
        
        walletService.errorNode = errorNode
        walletService.wallet = wallet
        walletService.activeAccount = activeAccount
        walletService.storage = storage
        walletService.settings = settings
        walletService.network = Property(1)
        walletService.web3Service = ethereumWeb3Service
        
        ethereumWeb3Service.wallet = wallet
        
        try! storage.bootstrap()
        walletService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRateService.bootstrap()
        passwordService.bootstrap()
        
        walletService
            .loadWallet()
            .done { wallet in
                self.isApplicationLoaded.send(true)
            }
            .catch {
                self.errorNode.send($0)
            }
    }
    
    private var storagePath: String {
        let sharedDir = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SHARED_GROUP
            )!
        return sharedDir.appendingPathComponent(DATABASE_NAME).absoluteString
    }
}
