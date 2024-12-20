//
//  ReviewSendTransactionViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import Wallet


class ReviewSendTransactionViewController: KeyboardScrollView, ModelVCProtocol {
    typealias ViewModel = ReviewSendTransactionViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sendETHLabel: UILabel!
    @IBOutlet weak var sendUSDLabel: UILabel!
    @IBOutlet weak var getsETHLabel: UILabel!
    @IBOutlet weak var getsUSDLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    
    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmButtonRight: NSLayoutConstraint!
    @IBOutlet weak var fingerButton: UIButton!
    
    @IBOutlet weak var txSendingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var txSendingIndicatorCenterX: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIBarButtonItem!

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
        
        let activeAccount = model.account.filter { $0 != nil }
        activeAccount
            .flatMapLatest { $0!.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        activeAccount
            .flatMapLatest { $0!.name }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        model.address.bind(to: addressLabel.reactive.text).dispose(in: reactive.bag)
        model.balanceString.bind(to: balanceLabel.reactive.text).dispose(in: reactive.bag)
        
        model.sendAmountETH.bind(to: sendETHLabel.reactive.text).dispose(in: reactive.bag)
        model.sendAmountUSD.bind(to: sendUSDLabel.reactive.text).dispose(in: reactive.bag)
        
        model.receiveAmountETH.bind(to: getsETHLabel.reactive.text).dispose(in: reactive.bag)
        model.receiveAmountUSD.bind(to: getsUSDLabel.reactive.text).dispose(in: reactive.bag)
        
        model.gasAmountString.bind(to: gasLabel.reactive.text).dispose(in: reactive.bag)
        
        model.passwordErrors.bind(to: passwordField.reactive.error).dispose(in: reactive.bag)
        passwordField.reactive.controlEvents(.editingDidBegin).map { _ in "" }
            .bind(to: passwordField.reactive.error ).dispose(in: reactive.bag)
        
        model.isSendingTx.map { !$0 }
            .bind(to: txSendingIndicator.reactive.isHidden).dispose(in: reactive.bag)
        model.isSendingTx.map { $0 == true ? "" : "Confirm"}
            .bind(to: confirmButton.reactive.title).dispose(in: reactive.bag)
        model.isSendingTx.map { !$0 }
            .bind(to: view.reactive.isUserInteractionEnabled).dispose(in: reactive.bag)
        
        backButton.reactive.tap.throttle(seconds: 0.5)
            .observeNext { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }.dispose(in: reactive.bag)
        
        setupFingerButton()
        setupKeyboardDismiss()
        setupSizes()
    }
    
    override func moveConstraints(keyboardHeight: CGFloat?) {
        super.moveConstraints(keyboardHeight: keyboardHeight)
    }
    
    private func setupFingerButton() {
        model.isBiometricEnabled.map { !$0 }.bind(to: fingerButton.reactive.isHidden).dispose(in: bag)
        
        model.isBiometricEnabled.with(weak: confirmButtonRight, txSendingIndicatorCenterX)
            .observeNext { isEnabled, confirmButtonRight, txSendingIndicatorCenterX in
                confirmButtonRight.constant = isEnabled ? 74 : 16
                txSendingIndicatorCenterX.constant = isEnabled ? -29 : 0
            }.dispose(in: bag)
        
        fingerButton.reactive.tap.throttle(seconds: 0.5)
            .bind(to: model.fingerAction).dispose(in: bag)
    }
    
    private func setupSizes() {
        if UIScreen.main.bounds.width > 320 {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
}


extension ReviewSendTransactionViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = ReviewSendTransactionViewModel(walletService: appCtx.walletService, ethWeb3Service: appCtx.ethereumWeb3Service, changeRateService: appCtx.changeRatesService, passwordService: appCtx.passwordService, settings: appCtx.settings)
        model.account.next(context.get(bean: "account")! as? AccountViewModel)
        model.address.next(context.get(bean: "address")! as! String)
        model.ethereumNetwork.next(context.get(bean: "network")! as! UInt64)
        model.sendAmount.next(context.get(bean: "sendAmount")! as! Double)
        model.gasAmount.next(context.get(bean: "gasAmount")! as! Double)
        model.balance.next(context.get(bean: "balance")! as! Double)
    
        let sendContext = context.get(context: SendFundsViewControllerContext.self)!
        model.closeModal.bind(to: sendContext.closeAction).dispose(in: model.bag)
        model.notificationNode.bind(to: appCtx.notificationNode).dispose(in: model.bag)
        
        model.bootstrap()
    }
}
