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
    @IBOutlet weak var accountBalanceLabel: UILabel!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signData: UILabel!
    
    let usdChangeRate = Property<Double>(0.0)
    let ethBalance = Property<Double?>(nil)
    let activeAccount = PassthroughSubject<AccountViewModel, Never>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Data"

        let reqData = request.data
        let networkId = request.networkId
        let ethereumWeb3Service = context.ethereumWeb3Service

        let account: Address
        do {
            account = try Address(hex: request.account)
        } catch {
            context.errorNode.send(OpenWalletError.eth_keychainWrongAccount(request.account))
            return
        }
        
        if let text = String(data: reqData, encoding: .utf8) {
            signData.text = text
        } else {
            signData.text = reqData.toHexString()
        }
        
        activeAccount
            .flatMapLatest { $0.emoji }
            .bind(to: accountEmojiLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        activeAccount
            .flatMapLatest { $0.name }
            .bind(to: accountNameLabel.reactive.text)
            .dispose(in: reactive.bag)
        
        activeAccount
            .flatMapLatest { account in
                ethereumWeb3Service.getBalance(accountId: account.id, networkId: networkId).signal
            }
            .suppressedErrors
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        context.wallet
            .filter { $0 != nil }
            .tryMap { wallet -> AccountViewModel in
                let activeAccount = wallet!.accounts.collection.first { (try? $0.eth_address() == account) ?? false }
                guard activeAccount != nil else {
                    throw OpenWalletError.eth_keychainWrongAccount(account.hex(eip55: false))
                }
                return activeAccount!
            }
            .pourError(into: context.errorNode)
            .bind(to: activeAccount)
            .dispose(in: reactive.bag)
        
        combineLatest(ethBalance.filter{$0 != nil}, usdChangeRate)
            .map { balance, rate in
                if let balance = balance {
                    let balanceETH = NumberFormatter.eth.string(from: balance as NSNumber)!
                    let balanceUSD = NumberFormatter.usd.string(from: (balance * rate) as NSNumber)!
                    return "\(balanceETH) · \(balanceUSD)"
                }
                return "unknown"
            }
            .bind(to: accountBalanceLabel.reactive.text)
            .dispose(in: bag)

        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, Swift.Error> in
                wallet!.eth_signData(account: account, data: reqData, networkId: networkId).signal
            }
            .pourError(into: context.errorNode)
            .with(weak: self)
            .observeNext { signedData, sself in
                sself.succeed(response: signedData)
            }.dispose(in: reactive.bag)
        
        context.changeRateService.changeRates[.Ethereum]!
            .bind(to: usdChangeRate)
            .dispose(in: reactive.bag)
    }
}
