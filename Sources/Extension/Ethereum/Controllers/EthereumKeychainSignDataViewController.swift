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
import OpenWallet
import Wallet

private typealias Address = OpenWallet.Address

class EthereumKeychainSignDataViewController: EthereumKeychainViewController<EthereumSignDataKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"
        
        signData.text = request.data.toHexString()

        let reqData = request.data
        let account: Address
        do {
            account = try Address(hex: request.account)
        } catch {
            context.errors.next(OpenWalletError.eth_keychainWrongAccount(request.account))
            return
        }
        
        let networkId = request.networkId
        
        let activeAccount = context.wallet
            .filter { $0 != nil }
            .mapError { $0 as Error }
            .map { wallet -> AccountViewModel in
                let activeAccount = wallet!.accounts.collection.first { (try? $0.eth_address() == account) ?? false }
                guard activeAccount != nil else {
                    throw OpenWalletError.eth_keychainWrongAccount(account.hex(eip55: false))
                }
                return activeAccount!
            }
            .suppressAndFeedError(into: context.errors)
        
        activeAccount
            .flatMapLatest { $0.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        activeAccount
            .flatMapLatest { $0.name }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)

        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, Swift.Error> in
                wallet!.wallet.eth_signData(account: account, data: reqData, networkId: networkId).signal
            }
            .pourError(into: context.errors)
            .with(weak: self)
            .observeNext { signedData, sself in
                sself.succeed(response: signedData)
            }.dispose(in: reactive.bag)
    }
}
