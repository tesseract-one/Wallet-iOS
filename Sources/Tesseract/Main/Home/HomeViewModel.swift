//
//  HomeViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import TesSDK
import PromiseKit

class HomeViewModel: ViewModel {
    typealias ToView = (name: String, context: RouterContextProtocol?)
    
    let sendAction = SafePublishSubject<Void>()
    let receiveAction = SafePublishSubject<Void>()
    
    let activeAccount = Property<Account?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    
    let transactions = MutableObservableArray<EthereumTransactionLog>()
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    let balanceUSD = Property<String>("")
    
    let goToSendView = SafePublishSubject<ToView>()
    let goToReceiveView = SafePublishSubject<ToView>()
    let closePopupView = SafePublishSubject<Void>()
    
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
        
        let sendContext = SendFundsViewControllerContext()
        sendContext.closeAction.bind(to: closePopupView).dispose(in: bag)
        sendAction.map { _ in (name: "SendFunds", context: sendContext) }
            .bind(to: goToSendView).dispose(in: bag)
        
        let receiveContext = ReceiveFundsViewControllerContext()
        receiveContext.closeAction.bind(to: closePopupView).dispose(in: bag)
        receiveAction.map { _ in (name: "ReceiveFunds", context: receiveContext) }
            .bind(to: goToReceiveView).dispose(in: bag)
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
    }
    
    func updateBalance() {
        transactionInfoService.updateBalance()
    }
}
