//
//  EthereumKeychainViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import ReactiveKit
import Material

protocol EthereumKeychainViewControllerBaseControls  {
    var acceptButton: UIButton! { get set }
    var passwordField: ErrorTextField! { get set }
}

class EthereumKeychainViewController<Request: OpenWalletRequestDataProtocol>: ExtensionViewController {
    var responseCb: ((Error?, Request.Response?) -> Void)!
    var request: Request!
    
    let runWalletOperation = SafePublishSubject<Void>()
    
    private var _passwordField: ErrorTextField {
        return (self as! EthereumKeychainViewControllerBaseControls).passwordField
    }
    
    private var _acceptButton: UIButton {
        return (self as! EthereumKeychainViewControllerBaseControls).acceptButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _passwordField.reactive.controlEvents(.editingDidBegin).map{_ in ""}.bind(to: _passwordField.reactive.error).dispose(in: reactive.bag)
        
        let acceptTap = _acceptButton.reactive.tap
            .throttle(seconds: 0.5)
            .with(latestFrom: _passwordField.reactive.text)
            .map{$0.1 ?? ""}
            .with(weak: context.walletService)
            .flatMapLatest { password, walletService in
                walletService.unlockWallet(password: password).signal
        }
        
        acceptTap.errorNode.map { _ in "Incorrect password" }.bind(to: _passwordField.reactive.error).dispose(in: reactive.bag)
        
        acceptTap.suppressedErrors.bind(to: runWalletOperation).dispose(in: reactive.bag)
    }
    
    func fail(error: Error) {
        responseCb(error, nil)
    }
    
    func succeed(response: Request.Response) {
        responseCb(nil, response)
    }
}
