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

class SignUpViewController: UIViewController, RouterView, ViewFactoryProtocol {
  
  private var viewModel: SignUpViewModelProtocol!
  
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
    
    passwordField.reactive.text.map{ $0 ?? ""}
      .bind(to: viewModel.password).dispose(in: bag)
    confirmPasswordField.reactive.text.map{ $0 ?? ""}
      .bind(to: viewModel.confirmPassword).dispose(in: bag)
    
    passwordField.reactive.controlEvents(.editingDidBegin)
      .merge(with: confirmPasswordField.reactive.controlEvents(.editingDidBegin))
      .with(latestFrom: viewModel.passwordError)
      .with(weak: confirmPasswordField)
      .observeNext { _, confirmPasswordField in
        confirmPasswordField.error = ""
      }.dispose(in: bag)
    
    signUpButton.reactive.tap.bind(to: viewModel.signUpAction).dispose(in: bag)
    signUpButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
    
    restoreKeyButton.reactive.tap.bind(to: viewModel.restoreKeyAction).dispose(in: bag)
    restoreKeyButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
    }.dispose(in: bag)
    
//    viewModel.signUpSuccessfully
//      .filter { $0 == true }
//      .with(weak: self)
//      .observeNext { _, sself in
//        sself.performSegue(withIdentifier: "ShowTermsOfService", sender: sself)
//      }.dispose(in: bag)
    viewModel.routeTo.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
    }.dispose(in: bag)
    
    viewModel.signUpSuccessfully
      .filter { $0 == false }
      .with(latestFrom: viewModel.passwordError)
      .with(weak: passwordField, confirmPasswordField)
      .observeNext { passwordErrorTouple, passwordField, confirmPasswordField in
        confirmPasswordField.error = passwordErrorTouple.1?.rawValue
        passwordField.text = ""
        confirmPasswordField.text = ""
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
    let vm = SignUpViewModel(appService: appCtx.applicationService)
    self.viewModel = vm
  }
}
