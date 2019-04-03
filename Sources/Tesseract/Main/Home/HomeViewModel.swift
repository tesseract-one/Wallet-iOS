//
//  HomeViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import PromiseKit
import Wallet


class HomeViewModel: ViewModel {
    typealias ToView = (name: String, context: RouterContextProtocol?)
    
    let wallet = Property<WalletViewModel?>(nil)
    let activeAccount = Property<Account?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    
    let isMoreThanOneAccount = Property<Bool>(false)

    let transactions = MutableObservableArray<EthereumTransactionLog>()
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    let balanceUSD = Property<String>("")
    
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    let transactionInfoService: TransactionInfoService
    
    init(ethWeb3Service: EthereumWeb3Service,
         changeRateService: ChangeRateService,
         transactionInfoService: TransactionInfoService) {
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        self.transactionInfoService = transactionInfoService
        
        super.init()
    }
        
    func bootstrap() {
        ethBalance
            .map { $0 == nil ? "unknown" : "\($0!.rounded(toPlaces: 6)) ETH" }
            .bind(to: balance)
            .dispose(in: bag)
        
        combineLatest(ethBalance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                balance == nil ? "unknown" : "$ \((balance! * rate).rounded(toPlaces: 2))"
            }
            .bind(to: balanceUSD)
            .dispose(in: bag)
        
        wallet.with(weak: self)
            .observeNext { wallet, sself in
                wallet!.accounts.map { $0.collection.count > 0 }
                    .bind(to: sself.isMoreThanOneAccount).dispose(in: wallet!.bag)
            }.dispose(in: bag)
    }
    
    func updateBalance() {
        transactionInfoService.updateBalance()
    }
}
