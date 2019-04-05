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
}
