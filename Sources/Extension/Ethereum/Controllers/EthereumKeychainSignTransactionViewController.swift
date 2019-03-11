//
//  EthereumKeychainSignTransactionViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import Material
import ReactiveKit
import Bond
import Web3

class EthereumKeychainSignTransactionViewController: EthereumKeychainViewController<OpenWalletEthereumSignTxKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var blurredView: UIView!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: ErrorTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "New Transaction"
        
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
            .flatMapLatest { (_, wallet) -> ResultSignal<EthereumSignedTransaction, AnyError> in
                guard let wallet = wallet else {
                    return ResultSignal<EthereumSignedTransaction, AnyError>.failure(AnyError(NSError()))
                }
                do {
                    let transaction = EthereumTransaction(
                        nonce: EthereumQuantity.bytes(Bytes(hex: req.nonce)),
                        gasPrice: EthereumQuantity.bytes(Bytes(hex: req.gasPrice)),
                        gas: EthereumQuantity.bytes(Bytes(hex: req.gas)),
                        from: try EthereumAddress(hex: req.from, eip55: false),
                        to:  try EthereumAddress(hex: req.to, eip55: false),
                        value: EthereumQuantity.bytes(Bytes(hex: req.value)),
                        data: EthereumData(raw: Bytes(hex: req.data))
                    )
                    let chainId = EthereumQuantity.bytes(Bytes(hex: req.chainId))
                    return wallet.eth_signTx(tx: transaction, chainId: chainId).signal
                } catch (let err) {
                    return ResultSignal<EthereumSignedTransaction, AnyError>.failure(AnyError(err))
                }
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signedTx, sself in
                var signData = Data(bytes: signedTx.r.makeBytes())
                signData.append(Data(bytes: signedTx.s.makeBytes()))
                signData.append(UInt8(signedTx.v.quantity) + 27)
                sself.succeed(response: "0x" + signData.toHexString())
            }
            .dispose(in: reactive.bag)
        
        blurView()
    }
    
    private func blurView() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.layout(visualEffectView).edges()
        blurredView.sendSubviewToBack(visualEffectView)

    }
}
