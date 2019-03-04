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

class HomeViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let goToView = SafePublishSubject<ToView>()
    
    let activeAccount = Property<TesSDK.Account?>(nil)
    let ethereumNetwork = Property<Int>(0)
    
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    let ethBalance = Property<Double?>(nil)
    
    let balance = Property<String>("")
    let balanceUSD = Property<String>("")
    
    let transactions = MutableObservableArray<EthereumTransactionLog>()
    
    init(ethWeb3Service: EthereumWeb3Service, changeRateService: ChangeRateService) {
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
        super.init()
    }
    
    func bootstrap() {
        let service = ethWeb3Service
        combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
            .flatMapLatest { accoundAndNet -> Signal<Double, AnyError> in
                service.getBalance(account: Int(accoundAndNet.0!.index), networkId: accoundAndNet.1).signal
            }
            .suppressError(logging: true)
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
            .flatMapLatest { accoundAndNet -> Signal<Array<EthereumTransactionLog>, AnyError> in
                service.getTransactions(account: Int(accoundAndNet.0!.index), networkId: accoundAndNet.1).signal
        }
        
        txs.toErrorSignal().map { _ in Array<EthereumTransactionLog>() }.bind(to: transactions).dispose(in: bag)
        
        txs.suppressError(logging: true).bind(to: transactions).dispose(in: bag)
    }
}
