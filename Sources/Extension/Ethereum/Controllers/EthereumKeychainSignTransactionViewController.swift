//
//  EthereumKeychainSignTransactionViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import MaterialTextField
import Bond
import OpenWallet
import EthereumWeb3
import Wallet

class EthereumKeychainSignTransactionViewController: EthereumKeychainViewController<EthereumSignTxKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    let isContract = Property<Bool>(false)
    let usdChangeRate = Property<Double>(0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Transaction"
        
        addressLabel.text = request.to
        let sendQuantity = EthereumQuantity.bytes(Bytes(hex: request.value)).quantity
        sendAmountLabel.text = String(sendQuantity.ethValue())
        
        let withFee = sendQuantity + EthereumQuantity.bytes(Bytes(hex: request.gas)).quantity * EthereumQuantity.bytes(Bytes(hex: request.gasPrice)).quantity
        gasFeeLabel.text = "\(String(withFee.ethValue())) ETH"
        
        totalAmountLabel.text = String(sendQuantity.ethValue() + withFee.ethValue())
        
        dataLabel.text = request.data.toHexString()
        
        let req = self.request!
        
        let activeAccount = context.wallet
            .filter { $0 != nil }
            .mapError { $0 as Error }
            .map { wallet -> Account in
                let activeAccount = wallet!.accounts.collection.first { (try? $0.eth_address().hex(eip55: false) == req.from.lowercased()) ?? false }
                guard activeAccount != nil else {
                    throw OpenWalletError.eth_keychainWrongAccount(req.from)
                }
                return activeAccount!
            }
            .suppressAndFeedError(into: context.errors)
        
        activeAccount
            .map { $0.associatedData[.emoji]?.string }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        activeAccount
            .map { $0.associatedData[.name]?.string }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, Swift.Error> in
                guard let wallet = wallet else {
                    return ResultSignal<Data, Swift.Error>.failure(NSError())
                }
                
                return wallet.wallet.eth_signTx(tx: req.transaction, networkId: req.networkId, chainId: req.chainIdInt).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signature, sself in
                sself.succeed(response: signature)
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
