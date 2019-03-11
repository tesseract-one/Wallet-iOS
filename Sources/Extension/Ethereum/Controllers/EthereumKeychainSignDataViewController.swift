//
//  EthereumKeychainSignDataViewController.swift
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

class EthereumKeychainSignDataViewController: EthereumKeychainViewController<OpenWalletEthereumSignDataKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    @IBOutlet weak var signData: UILabel!
    @IBOutlet weak var blurredView: UIView!
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var passwordField: ErrorTextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"
        
        signData.text = request.data
        
        let reqData = Data(hex: request.data)
        let account = request.account
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, AnyError> in
                wallet!.eth_signData(account: account.lowercased(), data: reqData).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signedData, sself in
                sself.succeed(response: "0x" + signedData.toHexString())
            }.dispose(in: reactive.bag)
        
        blurView()
    }
    
    private func blurView() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurredView.layout(visualEffectView).edges()
        blurredView.sendSubviewToBack(visualEffectView)
        
    }
}
