//
//  SignInViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond

enum SignInPasswordErrors: String {
  case short = "Password should be at least 8 characters long"
  case wrong = "Password is incorrect"
}

protocol SignInViewModelProtocol: ViewModelProtocol {
  var signInAction: SafePublishSubject<Void> { get }
  var restoreKeyAction: SafePublishSubject<Void> { get }
  var password: Property<String?> { get }
  var passwordError: Property<SignInPasswordErrors?> { get }
}

class SignInViewModel: ViewModel, SignInViewModelProtocol {
  private let appService: ApplicationService
  
  let signInAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String?>(nil) // to avoid first call
  let passwordError = Property<SignInPasswordErrors?>(nil)
  
  init (appService: ApplicationService) {
    self.appService = appService
    
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    passwordChecker().bind(to: passwordError).dispose(in: bag)
    
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
  
  private func passwordChecker() -> SafeSignal<SignInPasswordErrors?> {
    return signInAction
      .with(latestFrom: passwordError)
      .filter { $0.1 == nil }
      .with(latestFrom: password)
      .map { _, password -> SignInPasswordErrors? in
        if password == "qweqweqwe" {
          AppState.shared.unblockWallet()
          return nil
        }
        return SignInPasswordErrors.wrong
      }
  }
}
