//
//  SignInViewModel.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond

protocol SignInViewModelProtocol: ViewModelProtocol {
  var signInAction: SafePublishSubject<Void> { get }
  var restoreKeyAction: SafePublishSubject<Void> { get }
  var password: Property<String?> { get }
  var passwordError: Property<String?> { get }
}

class SignInViewModel: ViewModel, SignInViewModelProtocol {
  let signInAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String?>(nil) // to avoid first call
  let passwordError = Property<String?>(nil)
  
  override init () {
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    passwordChecker().bind(to: passwordError).dispose(in: bag)
    
    restoreKeyAction.observeNext { _ in
      print("Restore Key")
    }.dispose(in: bag)
  }
}

extension SignInViewModel {
  
  private func passwordValidator() -> SafeSignal<String?> {
    return password
      .filter { $0 != nil }
      .map { pwd -> String? in
        if pwd!.count < 8 {
          return "Password should be at least 8 characters long"
        }
        return nil
    }
  }
  
  private func passwordChecker() -> SafeSignal<String?> {
    return signInAction.with(weak: passwordError, password)
      .filter { $0.1.value == nil }
      .map { _, pe, password -> String? in
        if password.value == "qweqweqwe" {
          AppState.shared.unblockWallet()
          return nil
        }
        return "Password is incorrect"
      }
  }
}
