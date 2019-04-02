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
import UIKit


class ApplicationService {
    let bag = DisposeBag()
    
    var walletService: WalletService!
    
    var errorNode: SafePublishSubject<Swift.Error>!
    
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    
    var settings: UserDefaults!
    var ethereumNetwork: Property<UInt64>!
    
    func bootstrap() {
        bindRegistration()
        // Bootstrap Step 2
        setNetwork()
        exec()
    }
    
    private func exec() {
        let _ = walletService.loadWallet()
    }
    
    private func bindRegistration() {
        walletService.wallet.distinctUntilChanged()
            .observeIn(.immediateOnMain)
            .map { [weak self] wallet -> UIViewController? in
                switch wallet {
                case .empty: return UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
                case .notExist: return self?.registrationViewFactory.registrationView
                case .locked(_): return self?.registrationViewFactory.unlockView
                case .unlocked(_): return try! self?.walletViewFactory.viewController(for: .root)
                }
            }
            .with(weak: self)
            .observeNext { view, sself in
                if sself.rootContainer.view != nil {
                    sself.rootContainer.setViewController(vc: view!, animated: true)
                } else {
                    sself.rootContainer.setViewController(vc: view!, animated: false)
                }
            }
            .dispose(in: bag)
    }
    
    private func setNetwork() {
        if let network = settings.object(forKey: "ethereumNetwork") as? UInt64 {
            ethereumNetwork.next(network)
        } else {
            ethereumNetwork.next(1) // Main Network
            settings.set(UInt64(1), forKey: "ethereumNetwork")
        }
    }
}
