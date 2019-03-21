//
//  TransactionInfoService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/20/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import TesSDK
import Web3

class TransactionInfoService {
    let bag = DisposeBag()
    
    var web3Service: EthereumWeb3Service!
    
    var network: Property<UInt64>!
    var activeAccount: Property<Account?>!
    
    var balance: Property<Double?>!
    var transactions: Property<Array<EthereumTransactionLog>?>!
    
    private var updateTimer: Timer? = nil
    
    func bootstrap() {
        activeAccount
            .observeIn(.main)
            .with(weak: self)
            .observeNext { acc, sself in
                sself.checkTimer(account: acc)
            }
            .dispose(in: bag)
        
        combineLatest(network.distinct(), activeAccount)
            .observeIn(.main)
            .observeNext { [weak self] _, _ in
                self?.balance.next(nil)
                self?.updateBalance()
            }
            .dispose(in: bag)
        
        combineLatest(balance.distinct(), activeAccount)
            .observeIn(.main)
            .observeNext { [weak self] _,  _ in
                self?.updateTransactions()
            }
            .dispose(in: bag)
    }
    
    func updateBalance() {
        if let account = activeAccount.value {
            web3Service.getBalance(account: Int(account.index), networkId: network.value)
                .done(on: .main) { [weak self] balance in
                    self?.balance.next(balance)
                }
                .catch { [weak self] _ in
                    self?.balance.next(nil)
                }
        } else {
            balance.next(nil)
        }
    }
    
    private func updateTransactions() {
        if let account = activeAccount.value, let _ = balance.value {
            web3Service.getTransactions(account: Int(account.index), networkId: network.value)
                .done(on: .main) { [weak self] txs in
                    self?.transactions.next(
                        txs.sorted(by: { UInt64($0.timeStamp)! > UInt64($1.timeStamp)! })
                    )
                }
                .catch { [weak self] _ in
                    self?.transactions.next(nil)
                }
        } else {
            transactions.next(nil)
        }
    }
    
    private func checkTimer(account: Account?) {
        if let _ = account {
            if updateTimer == nil {
                updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
                    self?.updateBalance()
                }
            }
        } else {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
}
