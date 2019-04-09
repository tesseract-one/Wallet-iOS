//
//  ApplicationContext.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Wallet


class ApplicationContext: RouterContextProtocol {
    // let bag = DisposeBag()
    // Injected //
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!

    // State
    let wallet = Property<WalletViewModel?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    let activeAccount = Property<AccountViewModel?>(nil)
    
    let isApplicationStarted = Property<Bool>(false)
    
    let balance = Property<Double?>(nil)
    let transactions = Property<Array<EthereumTransactionLog>?>(nil)
    
    // Node to send critical errors
    public let errorNode = SafePublishSubject<Swift.Error>()
    public let notificationNode = SafePublishSubject<NotificationProtocol>()
    
    // Settings
    let settings: Settings = UserDefaults(suiteName: SHARED_GROUP)!
    
    // Services
    let applicationService = ApplicationService()
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service()
    let changeRatesService = ChangeRateService()
    let transactionService = TransactionInfoService()
    let passwordService = KeychainPasswordService()
    let notificationService = NotificationService()
    
    func bootstrap() {
        let storage = try! DatabaseWalletStorage(path: storagePath)
        
        walletService.storage = storage
        walletService.wallet = wallet
        walletService.errorNode = errorNode
        walletService.activeAccount = activeAccount
        walletService.settings = settings
        walletService.web3Service = ethereumWeb3Service
        walletService.network = ethereumNetwork
        
        applicationService.walletService = walletService
        applicationService.errorNode = errorNode
        applicationService.settings = settings
        applicationService.ethereumNetwork = ethereumNetwork
        
        ethereumWeb3Service.wallet = wallet
        
        transactionService.activeAccount = activeAccount
        transactionService.web3Service = ethereumWeb3Service
        transactionService.transactions = transactions
        transactionService.network = ethereumNetwork
        
        applicationService.rootContainer = rootContainer
        applicationService.registrationViewFactory = registrationViewFactory
        applicationService.walletViewFactory = walletViewFactory
        applicationService.notificationNode = notificationNode
        
        notificationService.rootContainer = rootContainer
        notificationService.notificationNode = notificationNode
        
        try! storage.bootstrap()
        
        notificationService.bootstrap()
        walletService.bootstrap()
        applicationService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRatesService.bootstrap()
        transactionService.bootstrap()
        passwordService.bootstrap()
    }
    
    private var storagePath: String {
        let sharedDir = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SHARED_GROUP
        )!
        return sharedDir.appendingPathComponent(DATABASE_NAME).absoluteString
    }
}
