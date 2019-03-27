//
//  SignUpModelView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import ReactiveKit
import Bond

enum SignUpPasswordErrors: String {
  case short = "Password should be at least 8 characters long"
  case different = "Passwords are different"
  case server = "Server error"
}

class SignUpViewModel: ViewModel, ForwardRoutableViewModelProtocol {
  let signUpAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String>("")
  let confirmPassword = Property<String>("")
  let passwordError = Property<SignUpPasswordErrors?>(nil)
  let signUpSuccessfully = Property<Bool?>(nil)
  
  let goToView = SafePublishSubject<ToView>()
  
  override init () {
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    
    setupSignUp()
    
    restoreKeyAction.map { _ in (name: "WalletType", context: nil) }
      .bind(to: goToView).dispose(in: bag)
  }
}

extension SignUpViewModel {
  
  private func passwordValidator() -> SafeSignal<SignUpPasswordErrors?> {
    return combineLatest(password, confirmPassword)
      .map { pwd1, pwd2 -> SignUpPasswordErrors? in
        if pwd1.count < 8 || pwd2.count < 8 {
          return SignUpPasswordErrors.short
        } else if pwd1 != pwd2 {
          return SignUpPasswordErrors.different
        }
        return nil
    }
  }
  
  private func setupSignUp() {
    signUpAction
      .with(latestFrom: passwordError)
      .filter { $0.1 != nil }
      .map { _ in false }
      .bind(to: signUpSuccessfully)
      .dispose(in: bag)
    
    let action = signUpAction
      .with(latestFrom: passwordError)
      .filter { $0.1 == nil }
      .map { _ in }
      .with(latestFrom: password)
    
    action.map { _ in true }.bind(to: signUpSuccessfully).dispose(in: bag)
    action.map { _, password in
      let context = TermsOfServiceViewControllerContext(password: password)
      return (name: "TermsOfService", context: context)
    }.bind(to: goToView).dispose(in: bag)
  }
}
