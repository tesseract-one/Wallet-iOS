//
//  EthereumKeychainSignDataViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import TesSDK
import ReactiveKit
import Bond

class EthereumKeychainSignDataViewController: EthereumKeychainViewController<OpenWalletEthereumSignDataKeychainRequest> {
    @IBOutlet weak var signData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"
        
        signData.text = request.data
        
        let reqData = Data(hex: request.data)
        let account = request.account
        
        runWalletOperation
            .with(latestFrom: context.walletService.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, AnyError> in
                wallet!.eth_signData(account: account.lowercased(), data: reqData).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signedData, sself in
                sself.succeed(response: "0x" + signedData.toHexString())
            }.dispose(in: reactive.bag)
    }
}
