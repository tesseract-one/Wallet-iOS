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
    var wallet: Property<Wallet?>!
    let isWalletLocked: Property<Bool> = Property(true)
    
    var errorNode: SafePublishSubject<AnyError>!
    
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    
    func bootstrap() {
        wallet.map { $0 == nil || $0!.isLocked }.bind(to: isWalletLocked).dispose(in: bag)
        bindRegistration()
        
        exec()
    }
    
    func unlockWallet(password: String) -> Promise<Void> {
        return wallet.value!.unlock(password: password)
            .done { [weak self] in
                self?.isWalletLocked.next(false)
            }
    }
    
    private func exec() {
        walletService.loadWallet().signal
            .suppressAndFeedError(into: errorNode)
            .bind(to: wallet)
    }
    
    private func bindRegistration() {
        combineLatest(wallet, isWalletLocked)
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
