//
//  SignUpViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/8/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SignUpViewController: KeyboardScrollView, ModelVCProtocol {
  typealias ViewModel = SignUpViewModel
  
  private(set) var model: ViewModel!
  
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var confirmPasswordField: NextResponderTextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var restoreKeyButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    passwordField.reactive.text.map { $0 ?? "" } // useless map actually, its already empty string
      .bind(to: model.password).dispose(in: bag)
    confirmPasswordField.reactive.text.map { $0 ?? "" }
      .bind(to: model.confirmPassword).dispose(in: bag)
    
    passwordField.reactive.controlEvents(.editingDidBegin)
      .merge(with: confirmPasswordField.reactive.controlEvents(.editingDidBegin))
      .map { _ in "" }
      .bind(to: confirmPasswordField.reactive.error)
      .dispose(in: bag)
    
    let signUpTap = signUpButton.reactive.tap.throttle(seconds: 0.5)
    signUpTap.bind(to: model.signUpAction).dispose(in: bag)
    signUpTap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
    
    let restoreKeyTap = restoreKeyButton.reactive.tap.throttle(seconds: 0.5)
    restoreKeyTap.bind(to: model.restoreKeyAction).dispose(in: bag)
    restoreKeyTap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
    
    let signUpUnsuccessfull =
      model.signUpSuccessfully
        .filter { $0 != nil }
        .with(latestFrom: model.passwordError)
        .filter { $0 != true && $1 != nil }

    signUpUnsuccessfull
      .map { $1!.rawValue }
      .bind(to: confirmPasswordField.reactive.error)
      .dispose(in: bag)
    signUpUnsuccessfull
      .map { _ in "" }
      .bind(to: passwordField.reactive.text)
      .dispose(in: bag)
    signUpUnsuccessfull
      .map { _ in "" }
      .bind(to: confirmPasswordField.reactive.text)
      .dispose(in: bag)
    
    goToViewAction.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
      }.dispose(in: bag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.isNavigationBarHidden = false
  }
}

extension SignUpViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    self.model = SignUpViewModel()
  }
}
