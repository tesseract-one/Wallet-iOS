//
//  SendFundsViewModel.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Wallet


class SendFundsViewModel: ViewModel, RoutableViewModelProtocol {
    let walletService: WalletService
    let ethWeb3Service: EthereumWeb3Service
    let changeRateService: ChangeRateService
    
    let scanQr = SafePublishSubject<Void>()
    let reviewAction = SafePublishSubject<Void>()
    
    let closeModal = SafePublishSubject<Void>()
    
    let activeAccount = Property<AccountViewModel?>(nil)
    
    let address = Property<String?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    
    let balance = Property<String>("")
    let ethBalance = Property<Double?>(nil)
    
    let sendAmount = Property<Double>(0.0)
    let sendAmountUSD = Property<String>("")
    let gasAmount = Property<Double>(0.0)
    let gas = Property<String>("")
    let receiveAmount = Property<Double>(0.0)
    let receiveAmountETH = Property<String>("")
    let receiveAmountUSD = Property<String>("")
    
    let goToView = SafePublishSubject<ToView>()
    let goBack = SafePublishSubject<Void>()
    
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
        
        setupReview()
    }
    
    func bootstrap() {
        let service = ethWeb3Service
        
        combineLatest(ethBalance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                if let balance = balance {
                    let balanceETH = NumberFormatter.eth.string(from: balance as NSNumber)!
                    let balanceUSD = NumberFormatter.usd.string(from: (balance * rate) as NSNumber)!
                    return "\(balanceETH) · \(balanceUSD)"
                }
                return "unknown"
            }
            .bind(to: balance)
            .dispose(in: bag)
        
        combineLatest(activeAccount.filter { $0 != nil }, ethereumNetwork.distinctUntilChanged())
            .flatMapLatest { account, net in
                service.getBalance(accountId: account!.id, networkId: net).signal
            }
            .suppressedErrors
            .bind(to: ethBalance)
            .dispose(in: bag)
        
        combineLatest(
            sendAmount.debounce(interval: 0.5),
            activeAccount.filter { $0 != nil },
            address.filter {$0 != nil && $0!.count == 42}.debounce(interval: 0.5),
            ethereumNetwork.distinctUntilChanged()
        )
            .flatMapLatest { amount, account, address, network in
                service.estimateSendTxGas(accountId: account!.id, to: address!, amountEth: amount, networkId: network).signal
            }
            .suppressedErrors
            .bind(to: gasAmount)
            .dispose(in: bag)
        
        combineLatest(sendAmount, changeRateService.changeRates[.Ethereum]!)
            .map { sendAmount, rate in
               NumberFormatter.usd.string(from: (sendAmount * rate) as NSNumber)!
            }
            .bind(to: sendAmountUSD)
            .dispose(in: bag)
        
        combineLatest(gasAmount, changeRateService.changeRates[.Ethereum]!)
            .map { gasAmount, rate in
                let gasAmountETHString = NumberFormatter.eth.string(from: gasAmount as NSNumber)!
                let gasAmountUSD = gasAmount * rate
                
                if gasAmount < 0.01 {
                    return "\(gasAmountETHString) < 0,01 USD"
                }
                
                let gasAmountUSDString = NumberFormatter.usd.string(from: gasAmountUSD as NSNumber)!
                return "\(gasAmountETHString) ≈ \(gasAmountUSDString)"
            }
            .bind(to: gas)
            .dispose(in: bag)
        
        combineLatest(sendAmount, gasAmount).map {$0 - $1}.bind(to: receiveAmount).dispose(in: bag)
        
        receiveAmount.map { NumberFormatter.eth.string(from: $0 as NSNumber)! }.bind(to: receiveAmountETH).dispose(in: bag)
        
        combineLatest(receiveAmount, changeRateService.changeRates[.Ethereum]!)
            .map { receiveAmount, rate in
                NumberFormatter.usd.string(from: (receiveAmount * rate) as NSNumber)!
            }
            .bind(to: receiveAmountUSD)
            .dispose(in: bag)
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
                    ("sendAmount", sself.sendAmount.value)
                )
                return (name: "ReviewSendTransaction", context: context)
            }
            .bind(to: goToView)
            .dispose(in: bag)
    }
}
