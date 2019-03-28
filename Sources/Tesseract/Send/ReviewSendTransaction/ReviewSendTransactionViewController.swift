//
//  ReviewSendTransactionViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import ReactiveKit
import Bond

class ReviewSendTransactionViewController: KeyboardScrollView, ModelVCProtocol {
    typealias ViewModel = ReviewSendTransactionViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var sentAmount: UILabel!
    @IBOutlet weak var sentAmountInUSD: UILabel!
    @IBOutlet weak var recieveAmount: UILabel!
    @IBOutlet weak var recieveAmountInUSD: UILabel!
    @IBOutlet weak var gasAmount: UILabel!
    @IBOutlet weak var gasAmountInUSD: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonRight: NSLayoutConstraint!
    @IBOutlet weak var fingerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        goBack.observeNext { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.dispose(in: reactive.bag)
        
        confirmButton.reactive.tap
            .throttle(seconds: 0.5)
            .with(latestFrom: passwordField.reactive.text)
            .map { _, password in password ?? "" }
            .bind(to: model.send)
            .dispose(in: reactive.bag)
        
        model.amountString.bind(to: sentAmount.reactive.text).dispose(in: reactive.bag)
        model.amountUSD.bind(to: sentAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.receiveAmountString.bind(to: recieveAmount.reactive.text).dispose(in: reactive.bag)
        model.receiveAmountUSD.bind(to: recieveAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.gasAmountString.bind(to: gasAmount.reactive.text).dispose(in: reactive.bag)
        model.gasAmountUSD.bind(to: gasAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.address.bind(to: address.reactive.text).dispose(in: reactive.bag)
        model.balanceString.bind(to: balance.reactive.text).dispose(in: reactive.bag)
        
        model.error.observeNext { [weak self] error in
            let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }.dispose(in: reactive.bag)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupFingerButton()
        setupKeyboardDismiss()
    }
    
    override func moveConstraints(keyboardHeight: CGFloat?) {
        super.moveConstraints(keyboardHeight: keyboardHeight)
        
        if UIScreen.main.bounds.height < 600 {
            if keyboardHeight != nil {
                navigationController?.navigationBar.prefersLargeTitles = false
            } else {
                navigationController?.navigationBar.prefersLargeTitles = true

            }
            UIView.animate(withDuration: 1.0) {
                self.navigationController?.navigationBar.layoutIfNeeded()
            }
        }
    }
    
    private func setupFingerButton() {
        model.isBiometricEnabled.map { !$0 }.bind(to: fingerButton.reactive.isHidden).dispose(in: bag)
        
        model.isBiometricEnabled.with(weak: confirmButtonRight)
            .observeNext { isEnabled, confirmButtonRight in
                confirmButtonRight.constant = isEnabled ? 74 : 16
            }.dispose(in: bag)
        
        fingerButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.fingerAction).dispose(in: bag)
    }
}


extension ReviewSendTransactionViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = ReviewSendTransactionViewModel(walletService: appCtx.walletService, ethWeb3Service: appCtx.ethereumWeb3Service, changeRateService: appCtx.changeRatesService, passwordService: appCtx.passwordService, settings: appCtx.settings)
        model.account.next(context.get(bean: "account")! as? Account)
        model.address.next(context.get(bean: "address")! as! String)
        model.ethereumNetwork.next(context.get(bean: "network")! as! UInt64)
        model.amount.next(context.get(bean: "amount")! as! Double)
        model.gasAmount.next(context.get(bean: "gasAmount")! as! Double)
        model.balance.next(context.get(bean: "balance")! as! Double)
    
        model.bootstrap()
    }
}
