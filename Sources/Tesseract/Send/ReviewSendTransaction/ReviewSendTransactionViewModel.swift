//
//  ReviewSendTransactionViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import TesSDK

enum SendError: String, Error {
    case wrongPassword = "Wrong password"
}

class ReviewSendTransactionViewModel: ViewModel, BackRoutableViewModelProtocol {
    let walletService: WalletService
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    let goBack = SafePublishSubject<Void>()
    
    let account = Property<Account?>(nil)
    let address = Property<String>("")
    let ethereumNetwork = Property<UInt64>(0)
    
    let balance = Property<Double>(0.0)
    let balanceString = Property<String>("")
    
    let gasAmount = Property<Double>(0.0)
    let amount = Property<Double>(0.0)
    
    let receiveAmountString = Property<String>("")
    let gasAmountString = Property<String>("")
    let amountString = Property<String>("")
    
    let gasAmountUSD = Property<String>("")
    let amountUSD = Property<String>("")
    let receiveAmountUSD = Property<String>("")
    
    let closeModal = SafePublishSubject<Void>()
    
    let error = SafePublishSubject<AnyError>()
    
    let sendTransaction = SafePublishSubject<String>()
    
    init(walletService: WalletService, ethWeb3Service: EthereumWeb3Service, changeRateService: ChangeRateService) {
        self.walletService = walletService
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        
        super.init()
        
        combineLatest(amount, gasAmount).map{"\(($0 - $1).rounded(toPlaces: 10)) ETH"}.bind(to: receiveAmountString).dispose(in: bag)
        combineLatest(amount, gasAmount, changeRateService.changeRates[.Ethereum]!)
            .map{"\((($0 - $1)*$2).rounded(toPlaces: 2)) USD"}.bind(to: receiveAmountUSD).dispose(in: bag)
        
        combineLatest(amount, changeRateService.changeRates[.Ethereum]!)
            .map{"\(($0 * $1).rounded(toPlaces: 2)) USD"}.bind(to: amountUSD).dispose(in: bag)
        amount.map{"\($0) ETH"}.bind(to: amountString).dispose(in: bag)
        
        combineLatest(gasAmount, changeRateService.changeRates[.Ethereum]!)
            .map{"\(($0 * $1).rounded(toPlaces: 2)) USD"}.bind(to: gasAmountUSD).dispose(in: bag)
        gasAmount.map{String(format: "%f", $0)+" ETH"}.bind(to: gasAmountString).dispose(in: bag)
        
        balance.map{"\($0.rounded(toPlaces: 4)) ETH"}.bind(to: balanceString).dispose(in: bag)
    }
    
    func bootstrap() {
        sendTransaction.with(weak: self)
            .resultMap { password, sself -> (String, ReviewSendTransactionViewModel) in
                guard try sself.walletService.checkPassword(password: password) else {
                    throw AnyError(SendError.wrongPassword)
                }
                return (password, sself)
            }
            .tryMapWrapped { password, sself -> ReviewSendTransactionViewModel in
                try sself.walletService.unlockWallet(password: password)
                return sself
            }
            .flatMapLatest { sself in
                sself.ethWeb3Service.sendEthereum(
                    account: Int(sself.account.value!.index),
                    to: sself.address.value,
                    amountEth: sself.amount.value,
                    networkId: sself.ethereumNetwork.value
                ).signal
            }
            .pourError(into: error)
            .bind(to: closeModal)
            .dispose(in: bag)
    }
}
