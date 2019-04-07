//
//  HomeViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import PromiseKit
import Wallet


class HomeViewModel: ViewModel {
    typealias ToView = (name: String, context: RouterContextProtocol?)
    
    let wallet = Property<WalletViewModel?>(nil)
    let activeAccount = Property<AccountViewModel?>(nil)
    let ethereumNetwork = Property<UInt64>(0)
    
    let isMoreThanOneAccount = Property<Bool>(false)

    let transactions = MutableObservableArray<EthereumTransactionLog>()
    
    let balance = Property<Double?>(nil)
    let balanceETH = Property<String>("")
    let balanceUSD = Property<String>("")
    
    let balanceUpdate = Property<Double?>(nil)
    let balanceUpdateUSD = Property<String>("")
    let balanceUpdateInPercent = Property<String>("")
    
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
    }
        
    func bootstrap() {
        activeAccount.flatMapLatest{ $0!.balance }.bind(to: balance).dispose(in: bag)
        
        balance
            .map { $0 == nil ? "unknown" : "\($0!.rounded(toPlaces: 4)) ETH" }
            .bind(to: balanceETH)
            .dispose(in: bag)
        
        combineLatest(balance, changeRateService.changeRates[.Ethereum]!)
            .map { balance, rate in
                balance == nil ? "unknown" : "\((balance! * rate).rounded(toPlaces: 2)) USD"
            }
            .bind(to: balanceUSD)
            .dispose(in: bag)
        
        transactions.with(latestFrom: activeAccount)
            .filter { $1 != nil }
            .map { transactions, activeAccount in
                let calendar = Calendar.current
                return transactions.collection.reduce(0.0) { sum, tx in
                    var newSum = sum
                    
                    guard calendar.isDateInToday(Date(timeIntervalSince1970: Double(UInt64(tx.timeStamp)!))) else {
                        return newSum
                    }
                    
                    let address = try! activeAccount!.eth_address().hex(eip55: false)
                    
                    // use 2 if like that for additional case, when user send money to himself
                    if address == tx.from {
                        newSum -= BigUInt(tx.value, radix: 10)!.ethValue()
                    }
                    
                    if address == tx.to {
                        newSum += BigUInt(tx.value, radix: 10)!.ethValue()
                    }
                    
                    return newSum
                }
            }
            .bind(to: balanceUpdate)
            .dispose(in: bag)
        
        combineLatest(balanceUpdate, changeRateService.changeRates[.Ethereum]!)
            .map { balanceUpdate, rate in
                guard let balanceUpdate = balanceUpdate else {
                    return "0.0 USD"
                }
                
                let balanceUpdateString = "\((balanceUpdate * rate).rounded(toPlaces: 2)) USD"
                return balanceUpdate > 0 ? "+" + balanceUpdateString : balanceUpdateString
            }
            .bind(to: balanceUpdateUSD)
            .dispose(in: bag)
        
        balanceUpdate.with(latestFrom: balance)
            .map { balanceUpdate, balance in
                guard let balance = balance, let balanceUpdate = balanceUpdate, balanceUpdate != 0 else {
                    return "0.0%"
                }
                
                guard balance - balanceUpdate > 0.0001 else {
                    return "100.0%"
                }
                
                let balanceUpdateAsPercent = "\((balanceUpdate / (balance - balanceUpdate)).rounded(toPlaces: 2))%"
                return balanceUpdate > 0 ? "+" + balanceUpdateAsPercent : balanceUpdateAsPercent
            }
            .bind(to: balanceUpdateInPercent)
            .dispose(in: bag)
        
        wallet.filter { $0 != nil }
            .flatMapLatest { $0!.accounts }
            .map { $0.collection.count > 1 }
            .bind(to: isMoreThanOneAccount)
            .dispose(in: bag)
    }
}
