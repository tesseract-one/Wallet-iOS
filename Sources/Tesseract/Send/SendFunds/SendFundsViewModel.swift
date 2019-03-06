//
//  SendFundsViewModel.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import TesSDK

class SendFundsViewModel: ViewModel, RoutableViewModelProtocol {
    let goBack = SafePublishSubject<Void>()
    let goToView = SafePublishSubject<ToView>()
    
    let scanQr = SafePublishSubject<Void>()
    let reviewAction = SafePublishSubject<Void>()
    
    let closeModal = SafePublishSubject<Void>()
    
    let activeAccount = Property<TesSDK.Account?>(nil)
    
    let address = Property<String?>(nil)
    let ethereumNetwork = Property<Int>(0)
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    let balanceUSD = Property<String>("")
    
    let sendAmount = Property<Double>(0.0)
    let gasAmount = Property<Double>(0.0)
    let receiveAmount = Property<Double>(0.0)
    
    let walletService: WalletService
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    init(walletService: WalletService, ethWeb3Service: EthereumWeb3Service,
         changeRateService: ChangeRateService) {
        
        self.walletService = walletService
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
        super.init()
        
        let scanQrContext = ScanQRViewControllerContext()
        scanQr.map {
            (name: "ScanQR", context: scanQrContext)
        }.bind(to: goToView).dispose(in: bag)
        
        scanQrContext.cancel.bind(to: closeModal).dispose(in: bag)
        let qrAddress = scanQrContext.qrCode.filter {
            $0.hasPrefix("ethereum:")
        }
        .map { String($0[$0.index($0.startIndex, offsetBy: "ethereum:".count)...]) }
        
        qrAddress.bind(to: address).dispose(in: bag)
        qrAddress.map { _ in }.bind(to: closeModal).dispose(in: bag)
        
        ethBalance
            .map { $0 == nil ? "unknown" : "\($0!) ETH" }
            .bind(to: balance)
            .dispose(in: bag)
        
        combineLatest(ethBalance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                balance == nil ? "unknown" : "$ \((balance! * rate).rounded(toPlaces: 2))"
            }
            .bind(to: balanceUSD)
            .dispose(in: bag)
        
        setupReview()
    }
    
    func bootstrap() {
        let service = ethWeb3Service
        combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinct())
            .flatMapLatest { account, net in
                service.getBalance(account: Int(account!.index), networkId: net).signal
            }
            .suppressedErrors
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        combineLatest(
            sendAmount.debounce(interval: 0.5),
            activeAccount.filter { $0 != nil },
            address.filter {$0 != nil && $0!.count == 42}.debounce(interval: 0.5),
            ethereumNetwork.distinct()
        ).flatMapLatest { amount, account, address, network in
            service.estimateSendTxGas(account: Int(account!.index), to: address!, amountEth: amount, networkId: network).signal
        }
        .suppressedErrors
        .bind(to: gasAmount)
        .dispose(in: bag)
        
        combineLatest(sendAmount, gasAmount).map {$0 - $1}.bind(to: receiveAmount).dispose(in: bag)
    }
    
    func setupReview() {
        reviewAction
            .with(weak: self)
            .map { sself in
                let context = DictionaryRouterContext(dictionaryLiteral:
                    ("account", sself.activeAccount.value!),
                    ("address", sself.address.value!),
                    ("network", sself.ethereumNetwork.value),
                    ("balance", sself.ethBalance.value ?? 0.0),
                    ("gasAmount", sself.gasAmount.value),
                    ("amount", sself.sendAmount.value)
                )
                return (name: "ReviewSendTransaction", context: context)
            }
            .bind(to: goToView)
            .dispose(in: bag)
    }
}
