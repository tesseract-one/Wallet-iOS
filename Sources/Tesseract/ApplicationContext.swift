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
    let wallet: Property<Wallet?> = Property(nil)
    
    // Node to send critical errors
    public let errorNode = SafePublishSubject<AnyError>()
    
    // Services
    let applicationService = ApplicationService()
    let walletService = WalletService()
    
    func bootstrap() {
        walletService.wallet = wallet
        walletService.errorNode = errorNode
        
        applicationService.walletService = walletService
        applicationService.errorNode = errorNode
        
        applicationService.rootContainer = rootContainer
        
        applicationService.registrationViewFactory = registrationViewFactory
        applicationService.walletViewFactory = walletViewFactory
        
        walletService.bootstrap()
        applicationService.bootstrap()
    }
}
