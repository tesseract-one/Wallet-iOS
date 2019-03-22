//
//  SignInViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond
import PromiseKit
import Foundation

enum SignInPasswordErrors: String {
    case short = "Password should be at least 8 characters long"
    case wrong = "Password is incorrect"
    case biometric = "Finger ID error"
}

enum BiometricFlow: Equatable {
    case EnterPassword
    case ShowYesNoPopup
    case ShowFingerPopup
    case DisallowBiometric
}

class SignInViewModel: ViewModel, ForwardRoutableViewModelProtocol {
    private let walletService: WalletService
    private let passwordService: KeychainPasswordService
    private let settings: UserDefaults
    
    let signInAction = SafePublishSubject<Void>()
    let restoreKeyAction = SafePublishSubject<Void>()
    
    let password = Property<String>("")
    let passwordError = Property<SignInPasswordErrors?>(nil)
    let signInSuccessfully = Property<Bool?>(nil)
    
    let goToView = SafePublishSubject<ToView>()
    
    let errors = SafePublishSubject<AnyError>()
    let biometricErrors = SafePublishSubject<AnyError>()
    
    let canLoadPassword = Property<Bool?>(nil)
    
    let showTouchIdPopup = SafePublishSubject<Void>()
    let touchIdPopupAnswer = Property<Bool?>(nil)
    
    let setBiometricEnabledSetting = Property<Bool?>(nil)
    
    let checkPassword = SafePublishSubject<Void>()
    let unlockWallet = SafePublishSubject<Void>()
    let faceBiometric = SafePublishSubject<Void>()
    let touchIdBiometric = SafePublishSubject<Void>()
    
    let biometricFlow = Property<BiometricFlow?>(nil)
    
    init (walletService: WalletService, passwordService: KeychainPasswordService, settings: UserDefaults) {
        self.walletService = walletService
        self.passwordService = passwordService
        self.settings = settings
        
        super.init()
        
        passwordValidator().bind(to: passwordError).dispose(in: bag)
        
        setupSignIn()
        
        restoreKeyAction.map { _ in (name: "RestoreWallet", context: nil) }
            .bind(to: goToView).dispose(in: bag)
    }
}

extension SignInViewModel {
    
    private func passwordValidator() -> SafeSignal<SignInPasswordErrors?> {
        return password
            .map { pwd -> SignInPasswordErrors? in
                if pwd.count < 8 {
                    return SignInPasswordErrors.short
                }
                return nil
        }
    }
    
    private func setupSignIn() {
        let biometricType = passwordService.getBiometricType()
        
        unlockWallet
            .with(latestFrom: password)
            .with(weak: walletService)
            .resultMap { pwdTuple, walletService in
                try walletService.unlockWallet(password: pwdTuple.1)
            }
            .pourError(into: errors)
            .map { _ in true }
            .bind(to: signInSuccessfully)
            .dispose(in: bag)
        
        signInAction
            .with(latestFrom: passwordError)
            .filter { $1 != nil }
            .map { _ in false }
            .bind(to: signInSuccessfully)
            .dispose(in: bag)
        
        signInAction
            .with(latestFrom: passwordError)
            .filter { $1 == nil }
            .map { _ in }
            .with(latestFrom: password)
            .with(weak: walletService)
            .resultMap { pwdTuple, walletService in
                try walletService.unlockWallet(password: pwdTuple.1)
            }
            .pourError(into: errors)
            .map { _ in }
            .bind(to: checkPassword)
            .dispose(in: bag)
        
        errors.map { _ in SignInPasswordErrors.wrong }.bind(to: passwordError).dispose(in: bag)
        errors.map { _ in false }.bind(to: signInSuccessfully).dispose(in: bag)
        
        if biometricType == .none || settings.object(forKey: "isBiometricEnabled") as? Bool == false {
            checkPassword.bind(to: unlockWallet).dispose(in: bag)
        } else if settings.object(forKey: "isBiometricEnabled") as? Bool == true {
            passwordService.canLoadPassword().signal
                .pourError(into: errors)
                .bind(to: canLoadPassword)
                .dispose(in: bag)
            
            canLoadPassword
                .filter { $0 == true }
                .map { _ in }
                .with(weak: passwordService)
                .flatMapLatest { passwordService in
                    passwordService.loadPasswordWithBiometrics().signal
                }
                .suppressedErrors
                .with(weak: walletService)
                .resultMap { password, walletService in
                    try walletService.unlockWallet(password: password)
                }
                .pourError(into: errors)
                .map { _ in true }
                .bind(to: signInSuccessfully)
                .dispose(in: bag)
            
            checkPassword.bind(to: unlockWallet).dispose(in: bag)
        } else {
            setBiometricEnabledSetting.filter{ $0 != nil }.with(weak: self).observeNext { isBiometricEnabled, sself in
                sself.settings.set(isBiometricEnabled!, forKey: "isBiometricEnabled")
            }
            .dispose(in: bag)
            
            if biometricType == .face {
                checkPassword
                    .with(latestFrom: biometricFlow)
                    .filter { $0.1 == nil || $0.1 == .ShowYesNoPopup }
                    .map { _ in }
                    .with(latestFrom: password)
                    .with(weak: passwordService)
                    .flatMapLatest { pwdTuple, passwordService in
                        passwordService.savePasswordWithBiometrics(password: pwdTuple.1).signal
                    }
                    .pourError(into: biometricErrors)
                    .map { _ in }
                    .bind(to: faceBiometric)
                    .dispose(in: bag)
                faceBiometric.map {
                    _ in true
                }.bind(to: setBiometricEnabledSetting).dispose(in: bag)
                faceBiometric.bind(to: unlockWallet).dispose(in: bag)
                
                checkPassword
                    .with(latestFrom: biometricFlow)
                    .filter { $0.1 == .EnterPassword }
                    .map { _ in }
                    .bind(to: unlockWallet)
                    .dispose(in: bag)
                
                biometricFlow.filter { $0 == .DisallowBiometric }.map { _ in false }
                    .bind(to: setBiometricEnabledSetting).dispose(in: bag)
                biometricFlow.filter { $0 == .DisallowBiometric }.map { _ in }
                    .bind(to: unlockWallet).dispose(in: bag)
               
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .userDisallow }
                    .map { _ in BiometricFlow.DisallowBiometric }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .userCancel }
                    .map { _ in BiometricFlow.EnterPassword }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .retryLimitExceeded }
                    .map { _ in BiometricFlow.ShowYesNoPopup }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                
            } else if biometricType == .touch {
                touchIdBiometric
                    .with(latestFrom: password)
                    .with(weak: passwordService)
                    .flatMapLatest { pwdTuple, passwordService in
                        passwordService.savePasswordWithBiometrics(password: pwdTuple.1).signal
                            .mapWrapped{pwdTuple.1}
                    }
                    .pourError(into: biometricErrors)
                    .map { _ in }
                    .bind(to: unlockWallet)
                    .dispose(in: bag)
                
                checkPassword
                    .with(latestFrom: biometricFlow)
                    .filter { $0.1 == nil || $0.1 == .ShowYesNoPopup }
                    .map { _ in }
                    .bind(to: showTouchIdPopup).dispose(in: bag)
                touchIdPopupAnswer.filter { $0 == true }.map { _ in }.bind(to: touchIdBiometric)
                touchIdPopupAnswer.filter { $0 == false }.map { _ in }.bind(to: unlockWallet)
                touchIdPopupAnswer.filter { $0 != nil }.bind(to: setBiometricEnabledSetting).dispose(in: bag)
                
                checkPassword
                    .with(latestFrom: biometricFlow)
                    .filter { $0.1 == .ShowFingerPopup }
                    .map { _ in }
                    .bind(to: touchIdBiometric)
                    .dispose(in: bag)
                checkPassword
                    .with(latestFrom: biometricFlow)
                    .filter { $0.1 == .EnterPassword }
                    .map { _ in }
                    .bind(to: unlockWallet)
                    .dispose(in: bag)
                
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .retryLimitExceeded }
                    .map { _ in BiometricFlow.ShowFingerPopup }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .userFallback }
                    .map { _ in BiometricFlow.EnterPassword }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                biometricErrors
                    .filter { $0.error as! KeychainPasswordService.BiometricalErrors == .userCancel }
                    .map { _ in BiometricFlow.ShowYesNoPopup }
                    .bind(to: biometricFlow)
                    .dispose(in: bag)
                
//                biometricErrors.filter { (anyError: AnyError) -> Bool in
//                    if case KeychainPasswordService.BiometricalErrors.internalError(_) = anyError.error {
//                        return true
//                    }
//                    return false
//                    }
//                    .observeNext { _ in print("INTERNAL")}.dispose(in: bag)
            }
        }
    }
}
