//
//  ReceiveFundsViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import Wallet


class ReceiveFundsViewModel: ViewModel, BackRoutableViewModelProtocol {
    let activeAccount = Property<AccountViewModel?>(nil)
    let notificationNode = SafePublishSubject<NotificationProtocol>()
    
    let address = Property<EthereumTypes.Address?>(nil)
    let qrCodeAddress = Property<String>("ethereum:")
    
    let ethereumNetwork = Property<UInt64>(0)
    
    let goBack = SafePublishSubject<Void>()
    
    let closeButtonAction = SafePublishSubject<Void>()
    let copyAction = SafePublishSubject<Void>()
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    
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
        combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinctUntilChanged())
            .flatMapLatest { account, net in
                service.getBalance(accountId: account!.id, networkId: net).signal
            }
            .suppressedErrors
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        activeAccount.filter { $0 == nil }.map { _ in nil }.bind(to: ethBalance).dispose(in: bag)
        
        activeAccount.map {try! $0?.eth_address()}.bind(to: address).dispose(in: bag)
        activeAccount.map {try! $0?.eth_address().hex(eip55: true) ?? ""}.map{"ethereum:" + $0}.bind(to: qrCodeAddress).dispose(in: bag)
        
        combineLatest(ethBalance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                guard let balance = balance else {
                    return "unknown"
                }
                
                let balanceETH = NumberFormatter.eth.string(from: balance as NSNumber)!
                let balanceUSD = NumberFormatter.usd.string(from: (balance * rate) as NSNumber)!
                return "\(balanceETH) · \(balanceUSD)"
            }
            .bind(to: balance)
            .dispose(in: bag)
        
        copyAction.with(latestFrom: address)
            .observeNext { _, address in
                UIPasteboard.general.string = address?.hex(eip55: true)
            }.dispose(in: bag)
        
        copyAction
            .map { _ in
                NotificationInfo(title: "Address copied to clipboard!", type: .message)
            }
            .bind(to: notificationNode)
            .dispose(in: bag)
    }
}
