//
//  ApplicationContext.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import TesSDK

class ApplicationContext: RouterContextProtocol {
    // let bag = DisposeBag()
    // Injected //
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    
    // State
    let wallet: Property<WalletState> = Property(.empty)
    let ethereumNetwork: Property<UInt64> = Property(4)
    let activeAccount: Property<Account?> = Property(nil)
    
    let balance = Property<Double?>(nil)
    let transactions = Property<Array<EthereumTransactionLog>?>(nil)
    
    // Node to send critical errors
    public let errorNode = SafePublishSubject<AnyError>()
    
    // Settings
    let settings = UserDefaults(suiteName: "group.io.gettes.wallet.shared")!
    
    // Services
    let applicationService = ApplicationService()
    let walletService = WalletService()
    let ethereumWeb3Service = EthereumWeb3Service()
    let changeRatesService = ChangeRateService()
    let transactionService = TransactionInfoService()
    let passwordService = KeychainPasswordService()
    
    func bootstrap() {
        walletService.storage = settings
        walletService.wallet = wallet
        walletService.errorNode = errorNode
        walletService.activeAccount = activeAccount
        
        applicationService.walletService = walletService
        applicationService.errorNode = errorNode
        
        ethereumWeb3Service.wallet = wallet
        
        transactionService.activeAccount = activeAccount
        transactionService.web3Service = ethereumWeb3Service
        transactionService.balance = balance
        transactionService.transactions = transactions
        transactionService.network = ethereumNetwork
        
        applicationService.rootContainer = rootContainer
        
        applicationService.registrationViewFactory = registrationViewFactory
        applicationService.walletViewFactory = walletViewFactory
        
        walletService.bootstrap()
        applicationService.bootstrap()
        ethereumWeb3Service.bootstrap()
        changeRatesService.bootstrap()
        transactionService.bootstrap()
        passwordService.bootstrap()
    }
}
