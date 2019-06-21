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
import OpenWallet


class ApplicationService: ExtensionViewControllerURLChannelDelegate {
    let bag = DisposeBag()
    
    var walletService: WalletService!
    
    var errorNode: SafePublishSubject<Swift.Error>!
    var notificationNode: SafePublishSubject<NotificationProtocol>!
    var isAppLoaded: Property<Bool>!
    
    weak var rootContainer: ViewControllerContainer!
    
    // Storyboards
    var registrationViewFactory: RegistrationViewFactory!
    var walletViewFactory: ViewFactoryProtocol!
    var urlHandlerViewFactory: ViewFactoryProtocol!
    
    var settings: Settings!
    var ethereumNetwork: Property<UInt64>!
    
    let isWalletLocked = Property<Bool?>(nil)
    
    let urlRequestVC = Property<ExtensionViewController?>(nil)
    
    let rootViewController = Property<UIViewController>(UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!)
    
    private let presentingUrlRequest = Property<Bool>(false)
    
    private var urlRequestArrivedTime: TimeInterval = 0
    
    func bootstrap() {
        errorNode.map { error in
                NotificationInfo(title: "Internal Error", description: error.localizedDescription, type: .error)
            }
            .bind(to: notificationNode)
            .dispose(in: bag)
        
        bindUrlHandling()
        bindRegistration()
        setNetwork()
        // Bootstrap Step 2
        exec()
    }
    
    func handle(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        if scheme.starts(with: TESSERACT_URL_SCHEME) {
            return true
        }
        guard scheme.starts(with: OPENWALLET_URL_API_PREFIX) else {
            return false
        }
        do {
            let prevRequestVC = urlRequestVC.value
            urlRequestArrivedTime = Date().timeIntervalSince1970
            
            let channel = try ExtensionViewControllerURLChannel(request: url)
            let vc = try! self.urlHandlerViewFactory.viewController() as! URLHandlerMainViewController
            
            channel.delegate = self
            vc.dataChannel = channel
            
            urlRequestVC.next(vc)
            
            if let reqVC = prevRequestVC {
                DispatchQueue.main.async {
                    (reqVC.dataChannel as! ExtensionViewControllerURLChannel).delegate = nil
                    reqVC.cancelRequest()
                }
            }
        } catch let err {
            errorNode.next(err)
            return false
        }
        return true
    }
    
    private func exec() {
        walletService.loadWallet()
            .done { _ in
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
            .observeIn(.main)
            .map { $0.0! }
            .with(weak: self)
            .map { isLocked, sself in
                return isLocked
                    ? sself.registrationViewFactory.unlockView
                    : try! sself.walletViewFactory.viewController(for: .root)
            }
            .bind(to: rootViewController)
            .dispose(in: bag)
        
        combineLatest(rootViewController, presentingUrlRequest.distinctUntilChanged())
            .filter { !$1 }
            .map { $0.0 }
            .distinctUntilChanged()
            .observeIn(.immediateOnMain)
            .with(weak: self)
            .observeNext { view, sself in
                if sself.rootContainer.view != nil {
                    sself.rootContainer.setView(vc: view, animated: true)
                } else {
                    sself.rootContainer.setView(vc: view, animated: false)
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
    
    private func runUrlRequest(vc: ExtensionViewController) {
        
        let handleRequest = {
            let timeSpent = Date().timeIntervalSince1970 - self.urlRequestArrivedTime
            self.rootContainer.showModalView(vc: vc, animated: timeSpent > 0.5, completion: nil)
        }
        
        if presentingUrlRequest.value {
            rootContainer.hideModalView(animated: false, completion: handleRequest)
        } else {
            presentingUrlRequest.next(true)
            handleRequest()
        }
    }
    
    func urlChannelGotResponse(channel: ExtensionViewControllerURLChannel, response: Data) {
        self.urlRequestVC.next(nil)
        rootContainer.hideModalView(animated: true) {
            self.presentingUrlRequest.next(false)
            DispatchQueue.main.async {
                let _ = channel.sendResponse(provider: self.rootContainer.view!, data: response)
            }
        }
    }
    
    private func bindUrlHandling() {
        combineLatest(urlRequestVC, isAppLoaded)
            .observeIn(.main)
            .observeNext { [weak self] vc, loaded in
                guard let vc = vc, loaded else { return }
                self?.runUrlRequest(vc: vc)
            }.dispose(in: bag)
    }
}
