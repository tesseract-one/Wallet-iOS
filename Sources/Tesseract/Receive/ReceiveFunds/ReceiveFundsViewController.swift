//
//  ReceiveFundsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ReceiveFundsViewController: UIViewController, ModelVCProtocol {
    typealias ViewModel = HomeViewModel
    
    private(set) var model: ViewModel!
    
    // MARK: Outlets
    //
    @IBOutlet weak var qrCodeImageView: QRCodeView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var balanceUSDLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ReceiveFundsViewController: ContextSubject {
    func apply(context: RouterContextProtocol) {
        let appCtx = context.get(context: ApplicationContext.self)!
        model = HomeViewModel(
            ethWeb3Service: appCtx.ethereumWeb3Service,
            changeRateService: appCtx.changeRatesService
        )
        
        appCtx.activeAccount.bind(to: model.activeAccount).dispose(in: model.bag)
        appCtx.ethereumNetwork.bind(to: model.ethereumNetwork).dispose(in: model.bag)
        
        model.bootstrap()
    }
}

