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

protocol SignInViewModelProtocol: ForwardRoutableViewModelProtocol {
  var signInAction: SafePublishSubject<Void> { get }
  var restoreKeyAction: SafePublishSubject<Void> { get }
  var password: Property<String?> { get }
  var passwordError: Property<SignInPasswordErrors?> { get }
  var signUpSuccessfully: Property<Bool?> { get }
}

class SignInViewModel: ViewModel, SignInViewModelProtocol {
  private let walletService: WalletService
  
  let signInAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String?>(nil) // to avoid first call
  let passwordError = Property<SignInPasswordErrors?>(nil)
  let signUpSuccessfully = Property<Bool?>(nil)
  
  let goToView = SafePublishSubject<ToView>()
  
  init (walletService: WalletService) {
    self.walletService = walletService
  
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    passwordChecker()
    
    restoreKeyAction.observeNext { _ in
      print("Restore Key")
    }.dispose(in: bag)
  }
}

extension SignInViewModel {
  
  private func passwordValidator() -> SafeSignal<SignInPasswordErrors?> {
    return password
      .filter { $0 != nil }
      .map { pwd -> SignInPasswordErrors? in
        if pwd!.count < 8 {
          return SignInPasswordErrors.short
        }
        return nil
    }
  }
  
  private func passwordChecker() {
    return signInAction
      .with(weak: passwordError)
      .filter { $1.value == nil }
      .with(latestFrom: password)
      .with(weak: walletService)
      .observeNext { touple, walletService in
        let (( _, passwordError ), password) = touple
        walletService.unlockWallet(password: password!)
        .catch { _ in
           passwordError.next(SignInPasswordErrors.wrong)
        }
      }.dispose(in: bag)
  }
}
