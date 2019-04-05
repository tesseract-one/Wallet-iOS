//
//  TransactionInfoService.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/20/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import ReactiveKit
import Wallet


class TransactionInfoService {
    let bag = DisposeBag()
    
    var web3Service: EthereumWeb3Service!
    
    var network: Property<UInt64>!
    var activeAccount: Property<AccountViewModel?>!
    
    var transactions: Property<Array<EthereumTransactionLog>?>!
   
    func bootstrap() {        
        combineLatest(
            activeAccount.filter { $0 != nil }.flatMapLatest{ $0!.balance.distinctUntilChanged() },
            activeAccount
        )
            .observeIn(.main)
            .observeNext { [weak self] _,  _ in
                self?.updateTransactions()
            }.dispose(in: bag)
    }
    
    private func updateTransactions() {
        if let account = activeAccount.value, let _ = account.balance.value {
            web3Service.getTransactions(accountId: account.id, networkId: network.value)
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
}
