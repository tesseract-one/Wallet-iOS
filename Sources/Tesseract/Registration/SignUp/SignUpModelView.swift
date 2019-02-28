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

protocol SignUpViewModelProtocol: ViewModelProtocol {
  var signUpAction: SafePublishSubject<Void> { get }
  var restoreKeyAction: SafePublishSubject<Void> { get }
  var password: Property<String?> { get }
  var confirmPassword: Property<String?> { get }
  var passwordError: Property<SignUpPasswordErrors?> { get }
  var signUpSuccessfully: Property<Bool?> { get }
  var routeTo: SafePublishSubject<(name: String, context: RouterContextProtocol?)> { get }
}

class SignUpViewModel: ViewModel, SignUpViewModelProtocol {
  let signUpAction = SafePublishSubject<Void>()
  let restoreKeyAction = SafePublishSubject<Void>()
  let password = Property<String?>(nil)
  let confirmPassword = Property<String?>(nil)
  let passwordError = Property<SignUpPasswordErrors?>(nil)
  let signUpSuccessfully = Property<Bool?>(nil)
  
  private let appService: ApplicationService
  
  let routeTo = SafePublishSubject<(name: String, context: RouterContextProtocol?)>()
  
  init (appService: ApplicationService) {
    self.appService = appService
    
    super.init()
    
    passwordValidator().bind(to: passwordError).dispose(in: bag)
    signUp().bind(to: signUpSuccessfully).dispose(in: bag)
        
    restoreKeyAction.observeNext { _ in
      print("Restore Key")
    }.dispose(in: bag)
  }
}

extension SignUpViewModel {
  
  private func passwordValidator() -> SafeSignal<SignUpPasswordErrors?> {
    return combineLatest(password, confirmPassword)
      .filter { $0 != nil && $1 != nil  }
      .map { pwd1, pwd2 -> SignUpPasswordErrors? in
        if pwd1!.count < 8 || pwd2!.count < 8 {
          return SignUpPasswordErrors.short
        } else if pwd1 != pwd2 {
          return SignUpPasswordErrors.different
        }
        return nil
    }
  }
  
  private func signUp() -> SafeSignal<Bool?> {
    return signUpAction
      .with(latestFrom: passwordError)
      .with(latestFrom: password)
      .with(weak: routeTo)
      .map { pwdErrorTouple, pwd, routeTo -> Bool? in
        if pwdErrorTouple.1 != nil {
          return false
        }
        print("Sign Up")
        routeTo.next("NAME")
        return true // add more logic
      }
  }
}
