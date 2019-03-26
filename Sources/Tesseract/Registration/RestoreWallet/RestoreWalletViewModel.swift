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

enum RestoreFormErrors: String {
    case mnemonic = "Mnemonic should contain 12 words"
    case shortPass = "Password should be at least 8 characters long"
    case differentPass = "Passwords are different"
    case wrong = "Mnemonic is incorrect"
}

class RestoreWalletViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    let restoreAction = SafePublishSubject<Void>()
    
    let mnemonic = Property<String>("")
    let password = Property<String>("")
    let confirmPassword = Property<String>("")
    let restoreFormError = Property<RestoreFormErrors?>(nil)
    let restoreWalletSuccessfully = Property<Bool?>(nil)
    let wasCreatedByMetamask = Property<Bool>(false)
    
    let errors = SafePublishSubject<AnyError>()
    
    let goToView = SafePublishSubject<ToView>()
    
    private let walletService: WalletService
    
    init (walletService: WalletService) {
        self.walletService = walletService
        
        super.init()
        
        restoreFormValidator().bind(to: restoreFormError).dispose(in: bag)
        
        setupRestoreWallet()
    }
}

extension RestoreWalletViewModel {
    
    private func restoreFormValidator() -> SafeSignal<RestoreFormErrors?> {
        return combineLatest(mnemonic, password, confirmPassword)
            .map { mnemonic, pwd1, pwd2 -> RestoreFormErrors? in
                let mnemonicWords = mnemonic.split(separator: " ").filter { word in
                    let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmedWord != ""
                }

                if mnemonicWords.count != 12  {
                    return RestoreFormErrors.mnemonic
                } else if pwd1.count < 8 || pwd2.count < 8 {
                    return RestoreFormErrors.shortPass
                } else if pwd1 != pwd2 {
                    return RestoreFormErrors.differentPass
                }
                return nil
        }
    }
    
    private func setupRestoreWallet() {
        restoreAction
            .with(latestFrom: restoreFormError)
            .filter { $0.1 != nil }
            .map { _ in false }
            .bind(to: restoreWalletSuccessfully)
            .dispose(in: bag)
        
        restoreAction
            .with(latestFrom: restoreFormError)
            .filter { $0.1 == nil }
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
            }.bind(to: goToView).dispose(in: bag)
        
        
        errors.map { _ in RestoreFormErrors.wrong }.bind(to: restoreFormError).dispose(in: bag)
        errors.map { _ in false }.bind(to: restoreWalletSuccessfully).dispose(in: bag)
    }
}

