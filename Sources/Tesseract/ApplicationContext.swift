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


class ApplicationContext: RouterContextProtocol, CommonContext {
    // let bag = DisposeBag()
    // Injected //
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    var urlHandlerViewFactory: ViewFactoryProtocol!

    // State
    let wallet = Property<WalletViewModel?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    let activeAccount = Property<AccountViewModel?>(nil)
    let isApplicationLoaded = Property<Bool>(false)
    
    let balance = Property<Double?>(nil)
    let transactions = Property<Array<EthereumTransactionLog>?>(nil)
    
    // Node to send critical errors
    public let errorNode = PassthroughSubject<Swift.Error, Never>()
    public let notificationNode = PassthroughSubject<NotificationProtocol, Never>()
    
    // Settings
    let settings: Settings = UserDefaults(suiteName: SHARED_GROUP)!
    
    // Services
    let applicationService = ApplicationService()
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service(
        apiSecret: TESSERACT_ETHEREUM_ENDPOINTS_SECRET
    )
    let changeRateService = ChangeRateService()
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
        applicationService.urlHandlerViewFactory = urlHandlerViewFactory
        applicationService.notificationNode = notificationNode
        applicationService.isAppLoaded = isApplicationLoaded
        
        notificationService.rootContainer = rootContainer
        notificationService.notificationNode = notificationNode
        
        try! storage.bootstrap()
        
        notificationService.bootstrap()
        walletService.bootstrap()
        applicationService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRateService.bootstrap()
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
