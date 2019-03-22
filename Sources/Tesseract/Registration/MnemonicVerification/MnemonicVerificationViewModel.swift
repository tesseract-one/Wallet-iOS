//
//  MnemonicVerificationViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import TesSDK

enum MnemonicVerificationError: String {
    case deffierent = "Mnemonics are different"
    case server = "Server error"
}

class MnemonicVerificationViewModel: ViewModel {
    private let password: String
    private let newWalletData: NewWalletData
    private let walletService: WalletService
    private let settings: UserDefaults
    
    let doneMnemonicVerificationAction = SafePublishSubject<Void>()
    let skipMnemonicVerificationAction = SafePublishSubject<Void>()
    let mnemonicText = Property<String>("")
    let mnemonicError = Property<MnemonicVerificationError?>(nil)
    let mnemonicVerifiedSuccessfully = Property<Bool?>(nil)
    
    let errors = SafePublishSubject<AnyError>()
    
    init (password: String, newWalletData: NewWalletData, walletService: WalletService, settings: UserDefaults) {
        self.password = password
        self.newWalletData = newWalletData
        self.walletService = walletService
        self.settings = settings
        
        super.init()
        
        mnemonicValidator().bind(to: mnemonicError).dispose(in: bag)
        
        setUpMnemonicVerification()
    }
}

extension MnemonicVerificationViewModel {
    
    private func mnemonicValidator() -> SafeSignal<MnemonicVerificationError?> {
        let mnemonic = self.newWalletData.mnemonic
        
        return mnemonicText
            .map { mnemonicText -> MnemonicVerificationError? in
                let trimmedMnemonicText = mnemonicText.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedMnemonicText != mnemonic {
                    return MnemonicVerificationError.deffierent
                }
                return nil
        }
    }
    
    private func setUpMnemonicVerification() {
        let password = self.password
        let newWalletData = self.newWalletData
        
        doneMnemonicVerificationAction
            .with(weak: mnemonicError)
            .filter { $1.value != nil }
            .map { _ in false }
            .bind(to: mnemonicVerifiedSuccessfully)
            .dispose(in: bag)
        
        let saveWallet =
            doneMnemonicVerificationAction
                .with(weak: mnemonicError)
                .filter { $1.value == nil }
                .map { _ in }
                .with(weak: walletService)
                .flatMapLatest { walletService in
                    walletService.newWallet(data: newWalletData, password: password).signal
                }
                .pourError(into: errors)
        
        
        saveWallet
            .with(weak: walletService)
            .observeNext { wallet, walletService in
                walletService.setWallet(wallet: wallet)
            }.dispose(in: bag)
        
        saveWallet
            .map { _ in true }
            .bind(to: mnemonicVerifiedSuccessfully)
            .dispose(in: bag)
        
        skipMnemonicVerificationAction
            .with(weak: walletService)
            .flatMapLatest { walletService in
                walletService.newWallet(data: newWalletData, password: password).signal
            }
            .observeIn(.immediateOnMain)
            .pourError(into: errors)
            .with(weak: walletService, settings)
            .observeNext { wallet, walletService, settings in
                settings.removeObject(forKey: "isBiometricEnabled")
                wallet.lock() // We will go to login for touch id setup
                walletService.setWallet(wallet: wallet)
            }.dispose(in: bag)
        
        errors.map { _ in MnemonicVerificationError.server }
            .bind(to: mnemonicError).dispose(in: bag)
    }
}
