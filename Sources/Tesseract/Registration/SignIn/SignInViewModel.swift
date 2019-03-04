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

enum SignInPasswordErrors: String {
  case short = "Password should be at least 8 characters long"
  case wrong = "Password is incorrect"
}

class SignInViewModel: ViewModel, ForwardRoutableViewModelProtocol {
  private let walletService: WalletService
  
  let signInAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String>("")
  let passwordError = Property<SignInPasswordErrors?>(nil)
  let signInSuccessfully = Property<Bool?>(nil)
  
  let goToView = SafePublishSubject<ToView>()
  
  init (walletService: WalletService) {
    self.walletService = walletService
  
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    
    setUpSignIn()
    
    restoreKeyAction.map { _ in (name: "RestoreFromMnemonic", context: nil) }
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
  
  private func setUpSignIn() {
    let errors = SafePublishSubject<AnyError>()
    
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
      .flatMapLatest { pwdTuple, walletService -> Signal<Void, AnyError> in
        return walletService.unlockWallet(password: pwdTuple.1).signal
      }
      .suppressAndFeedError(into: errors)
      .map { _ in true }
      .bind(to: signInSuccessfully)
      .dispose(in: bag)
    
    errors.map { _ in SignInPasswordErrors.wrong }.bind(to: passwordError).dispose(in: bag)
    errors.map { _ in false }.bind(to: signInSuccessfully).dispose(in: bag)
  }
}
