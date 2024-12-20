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
    var notificationNode: SafePublishSubject<NotificationProtocol>!
    
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    
    var settings: Settings!
    var ethereumNetwork: Property<UInt64>!
    
    let isAppLoaded = Property<Bool>(false)
    let isWalletLocked = Property<Bool?>(nil)
    
    let rootViewController = Property<UIViewController>(UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!)
    
    func bootstrap() {
        errorNode.map { error in
                NotificationInfo(title: "Internal Error", description: error.localizedDescription, type: .error)
            }
            .bind(to: notificationNode)
            .dispose(in: bag)
        
        bindRegistration()
        // Bootstrap Step 2
        setNetwork()
        exec()
    }
    
    private func exec() {
        walletService.loadWallet().done { _ in
            self.isAppLoaded.next(true)
            }.catch {
                self.errorNode.next($0)
        }
    }
    
    private func bindRegistration() {
        walletService.wallet
            .filter { $0 != nil }
            .distinctUntilChanged()
            .with(weak: self)
            .observeNext { wallet, sself in
                sself.isWalletLocked.next(nil)
                wallet!.isLocked.bind(to: sself.isWalletLocked).dispose(in: wallet!.bag)
            }.dispose(in: bag)
        
        walletService.wallet
            .filter { $0 == nil }
            .distinctUntilChanged()
            .map { _ in nil }
            .bind(to: isWalletLocked)
            .dispose(in: bag)
        
        combineLatest(walletService.wallet, isAppLoaded)
            .filter { $0 == nil && $1 }
            .map { _, _ in }
            .with(weak: self)
            .map { sself in
                sself.registrationViewFactory.registrationView
            }
            .bind(to: rootViewController)
            .dispose(in: bag)
        
        combineLatest(isWalletLocked.distinctUntilChanged(), isAppLoaded)
            .filter { $0 != nil && $1 }
            .map { $0.0! }
            .with(weak: self)
            .map { isLocked, sself in
                return isLocked
                    ? sself.registrationViewFactory.unlockView
                    : try! sself.walletViewFactory.viewController(for: .root)
            }
            .bind(to: rootViewController)
            .dispose(in: bag)
        
        rootViewController
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { view, sself in
                if sself.rootContainer.view != nil {
                    sself.rootContainer.setViewController(vc: view, animated: true)
                } else {
                    sself.rootContainer.setViewController(vc: view, animated: false)
                }
            }
            .dispose(in: bag)
    }
    
    private func setNetwork() {
        if let network = settings.number(forKey: .ethereumNetwork) as? UInt64 {
            ethereumNetwork.next(network)
        } else {
            ethereumNetwork.next(1) // Main Network
            settings.set(UInt64(1), forKey: .ethereumNetwork)
        }
    }
}
