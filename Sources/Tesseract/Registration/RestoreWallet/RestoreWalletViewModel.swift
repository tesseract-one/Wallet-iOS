//
//  RestoreWalletViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import Wallet


enum PasswordErrors: String, Error {
    case short = "Password should be at least 8 characters long"
    case different = "Passwords are different"
}
enum MnemonicErrors: String, Error {
    case size = "Mnemonic should contain 12 words"
    case wrong = "Mnemonic is incorrect"

}

class RestoreWalletViewModel: ViewModel {
    private let walletService: WalletService
    private let settings: Settings
    private let wasCreatedByMetamask: Bool
    
    let restoreAction = SafePublishSubject<Void>()
    
    let mnemonic = Property<String>("")
    let password = Property<String>("")
    let confirmPassword = Property<String>("")
    let restoreWalletSuccessfully = Property<Bool?>(nil)
    
    let errors = SafePublishSubject<Swift.Error>()
    let mnemonicError = Property<MnemonicErrors?>(nil)
    let passwordError = Property<PasswordErrors?>(nil)
    
    init (walletService: WalletService, settings: Settings, wasCreatedByMetamask: Bool) {
        self.walletService = walletService
        self.settings = settings
        self.wasCreatedByMetamask = wasCreatedByMetamask
        
        super.init()
        
        passwordValidator().bind(to: passwordError).dispose(in: bag)
        mnemonicValidator().bind(to: mnemonicError).dispose(in: bag)
        
        setupRestoreWallet()
    }
}

extension RestoreWalletViewModel {
    
    private func passwordValidator() -> SafeSignal<PasswordErrors?> {
        return combineLatest(password, confirmPassword)
            .map { pwd1, pwd2 -> PasswordErrors? in
                if pwd1.count < 8 || pwd2.count < 8 {
                    return PasswordErrors.short
                } else if pwd1 != pwd2 {
                    return PasswordErrors.different
                }
                return nil
            }
    }
    
    private func mnemonicValidator() -> SafeSignal<MnemonicErrors?> {
        return mnemonic.map { mnemonic -> MnemonicErrors? in
                let mnemonicWords = mnemonic.split(separator: " ").filter { word in
                    let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmedWord != ""
                }
                
                if mnemonicWords.count != 12  {
                    return MnemonicErrors.size
                }
                return nil
        }
    }
    
    private func setupRestoreWallet() {
        let wasCreatedByMetamask = self.wasCreatedByMetamask
        let restoreActionCheckPass = restoreAction
            .with(latestFrom: passwordError)
            .with(latestFrom: mnemonicError)
        
        restoreActionCheckPass.filter { $0.0.1 != nil || $0.1 != nil }
            .map { _ in false }
            .bind(to: restoreWalletSuccessfully)
            .dispose(in: bag)
        
        let settings = self.settings
        
        restoreActionCheckPass.filter { $0.0.1 == nil && $0.1 == nil }
            .map { _ in }
            .with(latestFrom: password)
            .map { $0.1 }
            .with(latestFrom: mnemonic)
            .with(weak: walletService)
            .tryMap { mnemonicAndPwd, walletService -> (WalletService, String, NewWalletData) in
                do {
                    let newWalletData = try walletService.restoreWalletData(mnemonic: mnemonicAndPwd.1, password: mnemonicAndPwd.0)
                     return (walletService, mnemonicAndPwd.0, newWalletData)
                } catch  {
                    throw MnemonicErrors.wrong
                }
            }
            .pourError(into: errors)
            .flatMapLatest { walletService, password, newWalletData in
                walletService.newWallet(data: newWalletData, password: password, isMetamask: wasCreatedByMetamask).signal
            }
            .observeIn(.immediateOnMain)
            .pourError(into: errors)
            .with(weak: walletService)
            .observeNext { wallet, walletService in
                settings.clearSettings()
                wallet.lock() // We will go to login for touch id setup
                walletService.setWallet(wallet: wallet)
            }.dispose(in: bag)
        
        
        errors.map { _ in MnemonicErrors.wrong }.bind(to: mnemonicError).dispose(in: bag)
        errors.map { _ in false }.bind(to: restoreWalletSuccessfully).dispose(in: bag)
    }
}
