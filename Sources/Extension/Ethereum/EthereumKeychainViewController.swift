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

class EthereumKeychainViewController<Request: OpenWalletRequestDataProtocol>: ExtensionViewController {
    var responseCb: ((Error?, Request.Response?) -> Void)!
    var request: Request!
    
    let runWalletOperation = SafePublishSubject<Void>()
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: ErrorTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordField.reactive.controlEvents(.editingDidBegin).map{_ in ""}.bind(to: passwordField.reactive.error)
        
        let acceptTap = acceptButton.reactive.tap
            .throttle(seconds: 0.5)
            .with(latestFrom: passwordField.reactive.text)
            .map{$0.1 ?? ""}
            .with(weak: context.walletService)
            .flatMapLatest { password, walletService in
                walletService.unlockWallet(password: password).signal
        }
        
        acceptTap.errorNode.map { _ in "Incorrect password" }.bind(to: passwordField.reactive.error).dispose(in: reactive.bag)
        
        acceptTap.suppressedErrors.bind(to: runWalletOperation).dispose(in: reactive.bag)
    }
    
    func fail(error: Error) {
        responseCb(error, nil)
    }
    
    func succeed(response: Request.Response) {
        responseCb(nil, response)
    }
}
