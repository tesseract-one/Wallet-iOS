//
//  ApplicationService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import PromiseKit
import TesSDK

class ApplicationService {
    let bag = DisposeBag()
    
    var walletService: WalletService!
    
    var errorNode: SafePublishSubject<AnyError>!
    
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    
    func bootstrap() {
        bindRegistration()
        // Bootstrap Step 2
        exec()
    }
    
    private func exec() {
        let _ = walletService.loadWallet()
    }
    
    private func bindRegistration() {
        combineLatest(walletService.wallet, walletService.isWalletLocked)
            .map { [weak self] wallet, isLocked in
                if wallet != nil && !isLocked {
                    return try! self?.walletViewFactory.viewController(for: .root)
                } else if wallet == nil {
                    return self?.registrationViewFactory.registrationView
                }
                return self?.registrationViewFactory.unlockView
            }
            .with(weak: self)
            .observeNext { view, sself in
                sself.rootContainer.view = view
            }
            .dispose(in: bag)
    }
}
