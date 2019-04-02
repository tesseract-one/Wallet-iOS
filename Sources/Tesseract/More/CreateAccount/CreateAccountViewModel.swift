//
//  CreateAccountViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import Wallet

class CreateAccountViewModel: ViewModel, BackRoutableViewModelProtocol {
    let walletService: WalletService
    
    let emojis = ["👨🏼‍💻", "👩🏿‍🎤", "👯‍♀️", "🦄", "😈", "💩", "👾", "🦹‍♀️"]
    
    let accountName = Property<String>("")
    let accountEmojiIndex = Property<Int>(0)
    let accountImages = MutableObservableArray<String>()
    
    let createAccountAction = SafePublishSubject<Void>()
    let validationError = SafePublishSubject<String?>()
    
    let goBack = SafePublishSubject<Void>()
    
    init(walletService: WalletService) {
        self.walletService = walletService
        
        super.init()
    }
    
    func bootstrap() {
        let emojis = self.emojis
        
        accountImages.replace(with: emojis)
        
        createAccountAction
            .with(latestFrom: accountName)
            .filter { $0.1 == "" }
            .map { _ in "Account name is empty" }
            .bind(to: validationError)
            .dispose(in: bag)
        
        createAccountAction
            .with(latestFrom: accountName)
            .filter { $0.1 != "" }
            .with(latestFrom: accountEmojiIndex)
            .with(weak: walletService)
            .flatMapLatest { args -> ResultSignal<Account, Swift.Error> in
                let (((_, name), emojiIndex), walletService) = args
                return walletService.newAccount(name: name, emoji: emojis[emojiIndex]).signal
            }
            .pourError(into: walletService.errorNode)
            .map { _ in }
            .bind(to: goBack)
            .dispose(in: bag)
    }
}
