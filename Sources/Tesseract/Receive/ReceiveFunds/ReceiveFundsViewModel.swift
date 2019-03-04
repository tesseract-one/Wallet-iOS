//
//  ReceiveFundsViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import TesSDK

class ReceiveFundsViewModel: ViewModel, BackRoutableViewModelProtocol {
    let activeAccount = Property<TesSDK.Account?>(nil)
    
    let address = Property<String?>(nil)
    let qrCodeAddress = Property<String>("ethereum:")
    
    let ethereumNetwork = Property<Int>(0)
    
    let goBack = SafePublishSubject<Void>()
    
    let closeButtonAction = SafePublishSubject<Void>()
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    let balanceUSD = Property<String>("")
    
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    init(ethWeb3Service: EthereumWeb3Service, changeRateService: ChangeRateService) {
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
        super.init()
        
        closeButtonAction.bind(to: goBack).dispose(in: bag)
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
        
        activeAccount.map {$0?.address}.bind(to: address).dispose(in: bag)
        activeAccount.map {$0?.address ?? ""}.map{"ethereum:" + $0}.bind(to: qrCodeAddress).dispose(in: bag)
        
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
    }
}
