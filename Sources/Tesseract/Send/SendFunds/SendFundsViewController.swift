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
    
    // MARK: Outlets
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceInUSDLabel: UILabel!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var sendAmountField: UITextField!
    @IBOutlet weak var gasAmountField: UITextField!
    @IBOutlet weak var recieverGetsAmountField: UITextField!
    
    @IBOutlet weak var scanQrButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var reviewButton: UIButton!
    
    var closeAction: SafePublishSubject<Void>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanQrButton.reactive.tap
            .throttle(seconds: 0.3)
            .bind(to: model.scanQr)
            .dispose(in: reactive.bag)
        
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
        
        model.closeModal.observeNext { [weak self] in
            if self?.presentedViewController != nil {
                self?.dismiss(animated: true, completion: nil)
            }
        }.dispose(in: reactive.bag)
        
        model.address.bidirectionalBind(to: addressField.reactive.text).dispose(in: reactive.bag)
        
        cancelButton.reactive.tap
            .throttle(seconds: 0.3)
            .bind(to: closeAction)
            .dispose(in: reactive.bag)
        
        reviewButton.reactive.tap
            .throttle(seconds: 0.3)
            .bind(to: model.reviewAction)
            .dispose(in: reactive.bag)
        
        goBack.bind(to: closeAction).dispose(in: reactive.bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: reactive.bag)
        model.balanceUSD.bind(to: balanceInUSDLabel.reactive.text).dispose(in: reactive.bag)
        
        sendAmountField.reactive.text
            .map { $0 == nil || $0 == "" ? 0.0 : Double($0!) ?? 0.0  }
            .bind(to: model.sendAmount)
            .dispose(in: reactive.bag)
        
        model.gasAmount
            .map{String(format: "%f", $0) + " ETH"}
            .bind(to: gasAmountField.reactive.text)
            .dispose(in: reactive.bag)
        model.receiveAmount
            .map{"\($0) ETH"}
            .bind(to: recieverGetsAmountField.reactive.text)
            .dispose(in: reactive.bag)
    }
}

extension SendFundsViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = SendFundsViewModel(
            walletService: appCtx.walletService,
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRatesService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        
        closeAction = context.get(context: SendFundsViewControllerContext.self)!.closeAction
        
        model.bootstrap()
    }
}
