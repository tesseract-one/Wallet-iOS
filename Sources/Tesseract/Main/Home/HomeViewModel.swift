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
    
    let activeAccount = Property<TesSDK.Account?>(nil)
    let ethereumNetwork = Property<Int>(0)
    let transactions = MutableObservableArray<EthereumTransactionLog>()
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    let balanceUSD = Property<String>("")
    
    let goToSendView = SafePublishSubject<ToView>()
    let goToReceiveView = SafePublishSubject<ToView>()
    let closePopupView = SafePublishSubject<Void>()
    
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    init(ethWeb3Service: EthereumWeb3Service, changeRateService: ChangeRateService) {
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
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
        let service = ethWeb3Service
        let balReq = combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
            .flatMapLatest { (accound, net) -> ResultSignal<Double> in
                service.getBalance(account: Int(accound!.index), networkId: net).signal
            }
        
        balReq
            .filter{$0.isFulfilled}
            .map{$0.value!}
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        balReq
            .filter{$0.isRejected}
            .map{_ in nil}
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        activeAccount.filter { $0 == nil }.map { _ in nil }.bind(to: ethBalance).dispose(in: bag)
        
        ethBalance
            .map { $0 == nil ? "unknown" : "\($0!) ETH" }
            .bind(to: balance)
            .dispose(in: bag)
        
        combineLatest(ethBalance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                balance == nil ? "unknown" : "$ \(balance! * rate)"
            }
            .bind(to: balanceUSD)
            .dispose(in: bag)
        
        let txs = combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
            .flatMapLatest { accoundAndNet -> ResultSignal<Array<EthereumTransactionLog>> in
                service.getTransactions(account: Int(accoundAndNet.0!.index), networkId: accoundAndNet.1).signal
            }
        
        txs.filter{$0.isFulfilled}.map{$0.value!}.bind(to: transactions).dispose(in: bag)
        txs.filter{$0.isRejected}.map{_ in Array<EthereumTransactionLog>()}.bind(to: transactions).dispose(in: bag)
    }
}
