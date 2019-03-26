//
//  RestoreWalletViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/6/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import TesSDK

enum PasswordErrors: String {
    case short = "Password should be at least 8 characters long"
    case different = "Passwords are different"
}
enum MnemonicErrors: String {
    case size = "Mnemonic should contain 12 words"
    case wrong = "Mnemonic is incorrect"

}

class RestoreWalletViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let restoreAction = SafePublishSubject<Void>()
    
    let mnemonic = Property<String>("")
    let password = Property<String>("")
    let confirmPassword = Property<String>("")
    let restoreWalletSuccessfully = Property<Bool?>(nil)
    let wasCreatedByMetamask = Property<Bool>(false)
    
    let errors = SafePublishSubject<AnyError>()
    let mnemonicError = Property<MnemonicErrors?>(nil)
    let passwordError = Property<PasswordErrors?>(nil)
    
    let goToView = SafePublishSubject<ToView>()
    
    private let walletService: WalletService
    
    init (walletService: WalletService) {
        self.walletService = walletService
        
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
        let restoreActionCheckPass = restoreAction
            .with(latestFrom: passwordError)
            .with(latestFrom: mnemonicError)
        
        restoreActionCheckPass.filter { $0.0.1 != nil || $0.1 != nil }
            .map { _ in false }
            .bind(to: restoreWalletSuccessfully)
            .dispose(in: bag)
        
        restoreActionCheckPass.filter { $0.0.1 == nil && $0.1 == nil }
            .map { _ in }
            .with(latestFrom: password)
            .map { $0.1 }
            .with(latestFrom: mnemonic)
            .with(weak: walletService)
            .resultMap { mnemonicAndPwd, walletService in
                try walletService.restoreWalletData(mnemonic: mnemonicAndPwd.1, password: mnemonicAndPwd.0)
            }
            .pourError(into: errors)
            .with(latestFrom: password)
            .with(latestFrom: wasCreatedByMetamask)
            .map { args in
                let ((walletData, password), wasCreatedByMetamask) = args
                let context = TermsOfServiceViewControllerContext(password: password, data: walletData, wasCreatedByMetamask: wasCreatedByMetamask)
                return (name: "TermsOfService", context: context)
            }
            .bind(to: goToView).dispose(in: bag)
        
        
        errors.map { _ in MnemonicErrors.wrong }.bind(to: mnemonicError).dispose(in: bag)
        errors.map { _ in false }.bind(to: restoreWalletSuccessfully).dispose(in: bag)
    }
}

