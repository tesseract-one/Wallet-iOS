//
//  EthereumKeychainSignTransactionViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import ReactiveKit
import MaterialTextField
import Bond
import Web3

class EthereumKeychainSignTransactionViewController: EthereumKeychainViewController<OpenWalletEthereumSignTxKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let isContract = Property<Bool>(false)
    let usdChangeRate = Property<Double>(0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Transaction"
        
        addressLabel.text = request.to
        let sendQuantity = EthereumQuantity.bytes(Bytes(hex: request.value)).quantity
        sendAmountLabel.text = String(sendQuantity.ethValue())
        
        let withFee = sendQuantity + EthereumQuantity.bytes(Bytes(hex: request.gas)).quantity * EthereumQuantity.bytes(Bytes(hex: request.gasPrice)).quantity
        gasFeeLabel.text = String(withFee.ethValue())
        
        totalAmountLabel.text = String(sendQuantity.ethValue() + withFee.ethValue())
        
        dataLabel.text = request.data
        
        let req = self.request!
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, AnyError> in
                guard let wallet = wallet.exists else {
                    return ResultSignal<Data, AnyError>.failure(AnyError(NSError()))
                }
                
                return wallet.eth_signTx(tx: req.transaction, networkId: req.networkId, chainId: req.chainIdInt).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signature, sself in
                sself.succeed(response: "0x" + signature.toHexString())
            }
            .dispose(in: reactive.bag)
        
        context.ethereumWeb3Service
            .ethereumAPIs.filter{$0 != nil}.map{_ in}
            .with(weak: context.ethereumWeb3Service)
            .flatMapLatest { service in
                service.isContract(address: req.to!, networkId: req.networkId).signal
            }
            .suppressedErrors
            .bind(to: isContract)
            .dispose(in: reactive.bag)
        
        context.changeRateService.changeRates[.Ethereum]!
            .bind(to: usdChangeRate)
            .dispose(in: reactive.bag)
    }
}
