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
    
    // MARK: Outlets
    //
    @IBOutlet weak var qrCodeImageView: QRCodeView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceUSDLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        goBack.bind(to: closeAction).dispose(in: reactive.bag)
        cancelButton.reactive.tap.bind(to: model.closeButtonAction).dispose(in: reactive.bag)
        
        model.qrCodeAddress.bind(to: qrCodeImageView.data).dispose(in: reactive.bag)
        model.address.bind(to: addressTextField.reactive.text).dispose(in: reactive.bag)
        
        model.balance.bind(to: balanceLabel.reactive.text).dispose(in: reactive.bag)
        model.balanceUSD.bind(to: balanceUSDLabel.reactive.text).dispose(in: reactive.bag)
    }
    
    // MARK: Default values
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
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

