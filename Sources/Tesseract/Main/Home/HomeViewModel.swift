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
  
  let balance = Property<String>("")
  let transactions = MutableObservableArray<Transaction>()
  
  init(ethWeb3Service: EthereumWeb3Service) {
    self.ethWeb3Service = ethWeb3Service
    
    super.init()
  }
  
  func bootstrap() {
    let service = ethWeb3Service
    combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
      .flatMapLatest { accoundAndNet -> Signal<Double, AnyError> in
        service.getBalance(account: Int(accoundAndNet.0!.index), networkId: accoundAndNet.1).signal
      }
    .suppressError(logging: true)
    .map { "\($0) ETH" }
    .bind(to: balance)
    .dispose(in: bag)
    
    activeAccount.filter { $0 == nil }.map { _ in "unknown" }.bind(to: balance).dispose(in: bag)
    
    let txs = combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
      .flatMapLatest { accoundAndNet -> Signal<Array<Transaction>, AnyError> in
        service.getTransactions(account: Int(accoundAndNet.0!.index), networkId: accoundAndNet.1).signal
      }
    
    txs.toErrorSignal().map { _ in Array<Transaction>() }.bind(to: transactions).dispose(in: bag)
    
    txs.suppressError(logging: true).bind(to: transactions).dispose(in: bag)
  }
}
