//
//  ReviewSendTransactionViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Wallet


enum SendError: String, Error {
    case wrongPassword = "Wrong password"
}

class ReviewSendTransactionViewModel: ViewModel, BackRoutableViewModelProtocol {
    let walletService: WalletService
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    let passwordService: KeychainPasswordService
    let settings: Settings
    
    let goBack = SafePublishSubject<Void>()
    
    let account = Property<AccountViewModel?>(nil)
    let address = Property<String>("")
    let ethereumNetwork = Property<UInt64>(0)
    
    let balance = Property<Double>(0.0)
    let balanceString = Property<String>("")
    
    let gasAmount = Property<Double>(0.0)
    let gasAmountString = Property<String>("")
    
    let sendAmount = Property<Double>(0.0)
    let sendAmountETH = Property<String>("")
    let sendAmountUSD = Property<String>("")
    
    let receiveAmountETH = Property<String>("")
    let receiveAmountUSD = Property<String>("")
    
    let closeModal = SafePublishSubject<Void>()
    
    let error = SafePublishSubject<Swift.Error>()
    
    let send = SafePublishSubject<String>()
    let fingerAction = SafePublishSubject<Void>()
    
    let isBiometricEnabled = Property<Bool>(false)
    let canLoadPassword = Property<Bool?>(nil)
    
    init(walletService: WalletService, ethWeb3Service: EthereumWeb3Service, changeRateService: ChangeRateService, passwordService: KeychainPasswordService, settings: Settings) {
        self.walletService = walletService
        self.ethWeb3Service = ethWeb3Service
        self.changeRateService = changeRateService
        self.passwordService = passwordService
        self.settings = settings
        
        super.init()
        
        combineLatest(sendAmount, gasAmount)
            .map{ NumberFormatter.eth.string(from: ($0 - $1) as NSNumber)! }
            .bind(to: receiveAmountETH)
            .dispose(in: bag)
        combineLatest(sendAmount, gasAmount, changeRateService.changeRates[.Ethereum]!)
            .map{ NumberFormatter.usd.string(from: (($0 - $1)*$2) as NSNumber)!}
            .bind(to: receiveAmountUSD)
            .dispose(in: bag)
        
        sendAmount.map{ NumberFormatter.eth.string(from: $0 as NSNumber)! }
            .bind(to: sendAmountETH).dispose(in: bag)
        combineLatest(sendAmount, changeRateService.changeRates[.Ethereum]!)
            .map{ NumberFormatter.usd.string(from: ($0 * $1) as NSNumber)! }
            .bind(to: sendAmountUSD)
            .dispose(in: bag)
        
        combineLatest(gasAmount, changeRateService.changeRates[.Ethereum]!)
            .map { gasAmount, rate in
                let gasAmountETH = NumberFormatter.eth.string(from: gasAmount as NSNumber)!
                let gasAmountUSD = NumberFormatter.usd.string(from: (gasAmount * rate) as NSNumber)!
                return "\(gasAmountETH) ≈ \(gasAmountUSD)"
            }
            .bind(to: gasAmountString)
            .dispose(in: bag)
        
        combineLatest(balance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                let balanceETH = NumberFormatter.eth.string(from: balance as NSNumber)!
                let balanceUSD = NumberFormatter.usd.string(from: (balance * rate) as NSNumber)!
                return "\(balanceETH) · \(balanceUSD)"
            }
            .bind(to: balanceString)
            .dispose(in: bag)
        
        if (settings.number(forKey: .isBiometricEnabled) as? Bool == true) &&
           (passwordService.getBiometricType() != .none) {
            isBiometricEnabled.next(true)
        }
    }
    
    func bootstrap() {
        send.with(weak: self)
            .resultMap { password, sself -> (String, ReviewSendTransactionViewModel) in
                guard try sself.walletService.checkPassword(password: password) else {
                    throw SendError.wrongPassword
                }
                return (password, sself)
            }
            .tryMapWrapped { password, sself -> ReviewSendTransactionViewModel in
                try sself.walletService.unlockWallet(password: password)
                return sself
            }
            .flatMapLatest { sself in
                sself.ethWeb3Service.sendEthereum(
                    accountId: sself.account.value!.id,
                    to: sself.address.value,
                    amountEth: sself.sendAmount.value,
                    networkId: sself.ethereumNetwork.value
                ).signal
            }
            .pourError(into: error)
            .bind(to: closeModal)
            .dispose(in: bag)
        
        goBack.with(weak: self).observeNext { _, sself in
                let walletService = sself.walletService
                DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(5)) {
                    walletService.updateBalance()
                }
            }.dispose(in: bag)
        
        fingerAction
            .with(weak: passwordService)
            .flatMapLatest { passwordService in
                passwordService.canLoadPassword().signal
            }
            .suppressedErrors
            .bind(to: canLoadPassword)
            .dispose(in: bag)
        
        canLoadPassword.filter { $0 == true }
            .map { _ in }
            .with(weak: passwordService)
            .flatMapLatest { passwordService in
                passwordService.loadPasswordWithBiometrics().signal
            }
            .suppressedErrors
            .bind(to: send)
            .dispose(in: bag)
    }
}
