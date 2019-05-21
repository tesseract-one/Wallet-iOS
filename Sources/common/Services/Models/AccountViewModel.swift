//
//  AccountViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/5/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import Wallet
import Ethereum

class AccountViewModel: ViewModel, Equatable {
    private let account: Account
    
    var id: String {
        return account.id
    }
    
    let name: Property<String>
    let emoji: Property<String>
    let balance = Property<Double?>(nil)
    
    init(account: Account) {
        self.account = account
        
        self.name = Property(account.associatedData[.name]?.string ?? "Main Account")
        self.emoji = Property(account.associatedData[.emoji]?.string ?? "\u{1F9B9}")
    }
    
    public func updateName(name: String) {
        account.associatedData[.name] = name.serializable
        self.name.next(name)
    }
    
    public func updateEmoji(emoji: String) {
        account.associatedData[.emoji] = emoji.serializable
        self.emoji.next(emoji)
    }
    
    public func updateBalance(balance: Double?) {
        self.balance.next(balance)
    }
    
    public func eth_address() throws -> Ethereum.Address {
        return try account.eth_address()
    }
    
    static func == (lhs: AccountViewModel, rhs: AccountViewModel) -> Bool {
        return lhs.account == rhs.account
    }
}

extension Account.AssociatedKeys {
    static let name = Account.AssociatedKeys(rawValue: "name")
    static let emoji = Account.AssociatedKeys(rawValue: "emoji")
}
