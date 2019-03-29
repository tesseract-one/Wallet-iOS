//
//  EthereumKeychainSignDataViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import MaterialTextField
import OpenWallet
import EthereumWeb3

class EthereumKeychainSignDataViewController: EthereumKeychainViewController<EthereumSignDataKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var passwordField: MFTextField!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"
        
        signData.text = request.data.toHexString()

        let reqData = request.data
        let account = try! Address(hex: request.account, eip55: false)
        let networkId = request.networkId

        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, AnyError> in
                wallet.exists!.eth_signData(account: account, data: reqData, networkId: networkId).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signedData, sself in
                sself.succeed(response: signedData)
            }.dispose(in: reactive.bag)
    }
}
