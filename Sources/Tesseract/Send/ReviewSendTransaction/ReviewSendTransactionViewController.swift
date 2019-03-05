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

class ReviewSendTransactionViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = ReviewSendTransactionViewModel
    
    var model: ViewModel!
    
    // MARK: Outlets
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

    override func viewDidLoad() {
        super.viewDidLoad()

        goBack.observeNext { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }.dispose(in: reactive.bag)
        
        confirmButton.reactive.tap
            .throttle(seconds: 0.3)
            .with(latestFrom: passwordField.reactive.text)
            .map { _, password in password ?? "" }
            .bind(to: model.sendTransaction)
            .dispose(in: reactive.bag)
        
        model.amountString.bind(to: sentAmount.reactive.text).dispose(in: reactive.bag)
        model.amountUSD.bind(to: sentAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.receiveAmountString.bind(to: recieveAmount.reactive.text).dispose(in: reactive.bag)
        model.receiveAmountUSD.bind(to: recieveAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.gasAmountString.bind(to: gasAmount.reactive.text).dispose(in: reactive.bag)
        model.gasAmountUSD.bind(to: gasAmountInUSD.reactive.text).dispose(in: reactive.bag)
        
        model.address.bind(to: address.reactive.text).dispose(in: reactive.bag)
        model.balanceString.bind(to: balance.reactive.text).dispose(in: reactive.bag)
    }
    
    // MARK: Default values
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}


extension ReviewSendTransactionViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = ReviewSendTransactionViewModel(walletService: appCtx.walletService, ethWeb3Service: appCtx.ethereumWeb3Service, changeRateService: appCtx.changeRatesService)
        model.account.next(context.get(bean: "account")! as? Account)
        model.address.next(context.get(bean: "address")! as! String)
        model.ethereumNetwork.next(context.get(bean: "network")! as! Int)
        model.amount.next(context.get(bean: "amount")! as! Double)
        model.gasAmount.next(context.get(bean: "gasAmount")! as! Double)
        model.balance.next(context.get(bean: "balance")! as! Double)
        
        let closeModal = context.get(bean: "closeModal")! as! SafePublishSubject<Void>
        model.closeModal.bind(to: closeModal).dispose(in: model.bag)
    }
}
