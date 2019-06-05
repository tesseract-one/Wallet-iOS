//
//  EthereumKeychainSignTransactionViewController.swift
//  Extension
//
//  Created by Yehor Popovych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond
import OpenWallet
import Ethereum
import Wallet

class EthereumKeychainSignTransactionViewController: EthereumKeychainViewController<EthereumSignTxKeychainRequest>, EthereumKeychainViewControllerBaseControls {
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var fingerButton: UIButton!
    @IBOutlet weak var passwordField: MaterialTextField!
    
    @IBOutlet weak var accountEmojiLabel: UILabel!
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    
    @IBOutlet weak var acceptBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var sendAmountETH: UILabel!
    @IBOutlet weak var sendAmountUSD: UILabel!
    @IBOutlet weak var receiveAmountETH: UILabel!
    @IBOutlet weak var receiveAmountUSD: UILabel!
    @IBOutlet weak var gasFeeLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    let isContract = Property<Bool>(false)
    let usdChangeRate = Property<Double>(0.0)
    let ethBalance = Property<Double?>(nil)
    let activeAccount = SafePublishSubject<AccountViewModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign Transaction"
        
        let req = self.request!
        let ethereumWeb3Service = context.ethereumWeb3Service
        
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
                ethereumWeb3Service.getBalance(accountId: account.id, networkId: req.networkId).signal
            }
            .suppressedErrors
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        context.wallet
            .filter { $0 != nil }
            .tryMap { wallet -> AccountViewModel in
                let activeAccount = wallet!.accounts.collection
                    .first { (try? $0.eth_address().hex(eip55: false) == req.from.lowercased()) ?? false }
                guard activeAccount != nil else {
                    throw OpenWalletError.eth_keychainWrongAccount(req.from)
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
        
        addressLabel.text = request.to
        
        let sendQuantity = try! Quantity(hex: request.value).quantity
        sendAmountETH.text = NumberFormatter.eth.string(from: sendQuantity.ethValue() as NSNumber)!
        usdChangeRate.map { rate in
                NumberFormatter.usd.string(from: (sendQuantity.ethValue() * rate) as NSNumber)!
            }
            .bind(to: sendAmountUSD.reactive.text)
            .dispose(in: bag)
        
        let withFee = try! sendQuantity
            + Quantity(hex: request.gas).quantity
            * Quantity(hex: request.gasPrice).quantity
        usdChangeRate
            .map { rate in
                let gasAmount = withFee.ethValue()
                let gasAmountETHString = NumberFormatter.eth.string(from: gasAmount as NSNumber)!
                let gasAmountUSD = gasAmount * rate
                
                if gasAmount < 0.01 {
                    return "\(gasAmountETHString) < 0,01 USD"
                }
                
                let gasAmountUSDString = NumberFormatter.usd.string(from: gasAmountUSD as NSNumber)!
                return "\(gasAmountETHString) ≈ \(gasAmountUSDString)"
            }
            .bind(to: gasFeeLabel.reactive.text)
            .dispose(in: bag)
        
        let receiveAmount = sendQuantity.ethValue() + withFee.ethValue()
        receiveAmountETH.text = NumberFormatter.eth.string(from: receiveAmount as NSNumber)!
        usdChangeRate.map { rate in
                NumberFormatter.usd.string(from: (receiveAmount * rate) as NSNumber)!
            }
            .bind(to: receiveAmountUSD.reactive.text)
            .dispose(in: bag)
        
        dataLabel.text = request.data.toHexString()
        
        runWalletOperation
            .with(latestFrom: context.wallet)
            .flatMapLatest { (_, wallet) -> ResultSignal<Data, Swift.Error> in
                guard let wallet = wallet else {
                    return ResultSignal<Data, Swift.Error>.failure(NSError())
                }
                var tx: Transaction
                var chainId: UInt64
                do {
                    tx = try req.transaction()
                    chainId = try req.chainIdInt()
                } catch let err {
                    return ResultSignal<Data, Swift.Error>.failure(err)
                }
                return wallet.eth_signTx(tx: tx, networkId: req.networkId, chainId: chainId).signal
            }
            .pourError(into: context.errorNode)
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
