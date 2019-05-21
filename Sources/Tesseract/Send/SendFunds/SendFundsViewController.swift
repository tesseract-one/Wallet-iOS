//
//  SendFundsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SendFundsViewControllerContext: RouterContextProtocol {
    let closeAction = SafePublishSubject<Void>()
}

class SendFundsViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = SendFundsViewModel
    
    var model: ViewModel!
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var sendAmountField: UITextField!
    @IBOutlet weak var sendAmountUSDLabel: UILabel!
    @IBOutlet weak var getsAmountLabel: UILabel!
    @IBOutlet weak var getsAmountUSDLabel: UILabel!
    @IBOutlet weak var gasAmountLabel: UILabel!
    
    @IBOutlet weak var scanQrButton: UIBarButtonItem!
    @IBOutlet weak var reviewButton: UIButton!
    
    let closeAction = SafePublishSubject<Void>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanQrButton.reactive.tap.throttle(seconds: 0.3)
            .bind(to: model.scanQr).dispose(in: reactive.bag)
        
        model.closeModal.observeNext { [weak self] in
            if self?.presentedViewController != nil {
                self?.dismiss(animated: true, completion: nil)
            }
        }.dispose(in: reactive.bag)
        
        let activeAccount = model.activeAccount.filter { $0 != nil }
        activeAccount
            .flatMapLatest { $0!.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        activeAccount
            .flatMapLatest { $0!.name }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        model.address
            .bidirectionalMap(
                to: { $0?.trimmingCharacters(in: .whitespaces) },
                from: { $0?.trimmingCharacters(in: .whitespaces) }
            )
            .bidirectionalBind(to: addressField.reactive.text)
            .dispose(in: reactive.bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: reactive.bag)
        
        sendAmountField.reactive.text
            .map { $0 == nil || $0 == "" ? 0.0 : Double($0!) ?? 0.0  }
            .bind(to: model.sendAmount)
            .dispose(in: reactive.bag)
        model.sendAmountUSD.bind(to: sendAmountUSDLabel.reactive.text).dispose(in: reactive.bag)
        
        model.receiveAmountETH.bind(to: getsAmountLabel.reactive.text).dispose(in: reactive.bag)
        model.receiveAmountUSD.bind(to: getsAmountUSDLabel.reactive.text).dispose(in: reactive.bag)
        
        model.gas.bind(to: gasAmountLabel.reactive.text).dispose(in: reactive.bag)
        
        model.isValidTransaction
            .bind(to: reviewButton.reactive.isEnabled).dispose(in: reactive.bag)
        
        goBack.bind(to: closeAction).dispose(in: reactive.bag)
        
        cancelButton.reactive.tap.throttle(seconds: 0.3)
            .bind(to: closeAction).dispose(in: reactive.bag)
        
        reviewButton.reactive.tap.throttle(seconds: 0.3)
            .bind(to: model.reviewAction).dispose(in: reactive.bag)
        
        goToViewAction.observeNext { [weak self] name, context in
            switch name {
            case "ScanQR":
                let vc = try! self?.viewController(for: .named(name: name), context: context)
                self?.present(vc!, animated: true, completion: nil)
            default:
                let vc = try! self?.viewController(for: .named(name: name), context: context)
                self?.navigationController?.pushViewController(vc!, animated: true)
            }
            }.dispose(in: reactive.bag)
        
        setupKeyboardDismiss()
        setupSizes()
    }
    
    private func setupSizes() {
        if UIScreen.main.bounds.width > 320 {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
}

extension SendFundsViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = SendFundsViewModel(
            walletService: appCtx.walletService,
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRateService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        
        closeAction.bind(to: context.get(context: SendFundsViewControllerContext.self)!.closeAction).dispose(in: reactive.bag)
        
        model.bootstrap()
    }
}
