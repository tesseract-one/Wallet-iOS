//
//  ReceiveFundsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class ReceiveFundsViewControllerContext: RouterContextProtocol {
    let closeAction = SafePublishSubject<Void>()
}

class ReceiveFundsViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = ReceiveFundsViewModel
    
    private(set) var model: ViewModel!
    
    var closeAction: SafePublishSubject<Void>!
    
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: QRCodeView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var copyButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        copyButton.reactive.tap.throttle(seconds: 0.5)
            .with(latestFrom: model.address)
            .observeNext { _, address in
                UIPasteboard.general.string = address?.hex(eip55: false)
            }.dispose(in: reactive.bag)
        
        goBack.bind(to: closeAction).dispose(in: reactive.bag)
        cancelButton.reactive.tap.bind(to: model.closeButtonAction).dispose(in: reactive.bag)
        
        model.activeAccount.filter { $0 != nil }
            .flatMapLatest { $0!.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        model.qrCodeAddress.bind(to: qrCodeImageView.data).dispose(in: reactive.bag)
        model.address.map{$0?.hex(eip55: false)}.bind(to: addressLabel.reactive.text).dispose(in: reactive.bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: reactive.bag)
    }
}

extension ReceiveFundsViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = ReceiveFundsViewModel(
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRatesService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        
        closeAction = context.get(context: ReceiveFundsViewControllerContext.self)!.closeAction
        
        model.bootstrap()
    }
}

