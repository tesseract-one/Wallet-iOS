//
//  WalletViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import Wallet
import PromiseKit
import Ethereum

class WalletViewModel: ViewModel, Equatable {
    let wallet: Wallet // don't use directly

    let accounts: MutableObservableArray<AccountViewModel>
    let isLocked: Property<Bool>
    
    init(wallet: Wallet) {
        self.wallet = wallet
        self.accounts = MutableObservableArray(wallet.accounts.map { AccountViewModel(account: $0 )})
        self.isLocked = Property(wallet.isLocked)
    }
    
    public func lock() {
        wallet.lock()
        isLocked.next(true)
    }
    
    public func unlock(password: String) throws {
        try wallet.unlock(password: password)
        isLocked.next(false)
    }
    
    public func checkPassword(password: String) -> Bool {
        return wallet.checkPassword(password: password)
    }
    
    public func changePassword(old: String, new: String) throws {
        try wallet.changePassword(old: old, new: new)
    }
    
    public func addAccount(emoji: String, name: String) throws -> AccountViewModel {
        let account = AccountViewModel(account: try wallet.addAccount())
        account.updateName(name: name)
        account.updateEmoji(emoji: emoji)
        accounts.append(account)
        return account
    }
    
    public func account(id: String) -> AccountViewModel? {
        return self.accounts.collection.first { $0.id == id }
    }
    
    static func == (lhs: WalletViewModel, rhs: WalletViewModel) -> Bool {
        return lhs.wallet == rhs.wallet
    }
    
    public func eth_signTypedData(
        account: Ethereum.Address, data: TypedData, networkId: UInt64
    ) -> Promise<Data> {
        return Promise<Data> { resolver in
            wallet.eth_signTypedData(
                account: account, data: data, networkId: networkId,
                response: resolver.resolve
            )
        }
    }
    
    public func eth_signTx(
        tx: Transaction, networkId: UInt64, chainId: UInt64
    ) -> Promise<Data> {
        return Promise<Data> { resolver in
            wallet.eth_signTx(
                tx: tx, networkId: networkId, chainId: chainId,
                response: resolver.resolve
            )
        }
    }
    
    public func eth_signData(
        account: Ethereum.Address, data: Data, networkId: UInt64
    ) -> Promise<Data> {
        return Promise<Data> { resolver in
            wallet.eth_signData(
                account: account, data: data, networkId: networkId,
                response: resolver.resolve
            )
        }
    }
}

private extension Resolver {
    func resolve(result: Swift.Result<T, SignProviderError>) {
        switch result {
        case .success(let val): fulfill(val)
        case .failure(let err): reject(err)
        }
    }
}
