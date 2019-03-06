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
import UIKit

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
        combineLatest(walletService.wallet.distinct(), walletService.isWalletLocked.distinct())
            .observeIn(.immediateOnMain)
            .map { [weak self] (wallet, isLocked) -> UIViewController? in
                if wallet != nil && !isLocked {
                    return try! self?.walletViewFactory.viewController(for: .root)
                } else if wallet == nil {
                    return self?.registrationViewFactory.registrationView
                }
                return self?.registrationViewFactory.unlockView
            }
            .with(weak: self)
            .observeNext { view, sself in
                if sself.rootContainer.view != nil && sself.rootContainer.view!.storyboard != view?.storyboard {
                    sself.rootContainer.setViewController(vc: view!, animated: true)
                } else {
                    sself.rootContainer.setViewController(vc: view!, animated: false)
                }
            }
            .dispose(in: bag)
    }
}
