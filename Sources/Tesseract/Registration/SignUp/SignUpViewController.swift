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

class SignUpViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = SignUpViewModel
  
  private(set) var model: ViewModel!
  
  // MARK: Outlets
  //  
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var confirmPasswordField: NextResponderTextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var restoreKeyButton: UIButton!
  
  // MARK: Lifecycle hooks
  //
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
    
    signUpButton.reactive.tap.bind(to: model.signUpAction).dispose(in: bag)
    signUpButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
    
    restoreKeyButton.reactive.tap.bind(to: model.restoreKeyAction).dispose(in: bag)
    restoreKeyButton.reactive.tap.with(weak: view).observeNext { view in
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
  
  // MARK: Default values
  //
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}

extension SignUpViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    let appCtx = context.get(context: ApplicationContext.self)!
    self.model = SignUpViewModel(walletService: appCtx.walletService)
  }
}
