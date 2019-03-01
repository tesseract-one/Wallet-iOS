//
//  SignInViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/21/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit
import Bond

class SignInViewController: UIViewController, ModelVCProtocol {
  typealias ViewModel = SignInViewModel
  
  private(set) var model: ViewModel!
  
  // MARK: Outlets
  //
  @IBOutlet weak var passwordField: NextResponderTextField!
  @IBOutlet weak var signInButton: UIButton!
  @IBOutlet weak var restoreKeyButton: UIButton!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    passwordField.reactive
      .controlEvents(.editingDidEnd)
      .with(weak: passwordField)
      .map { $0.text ?? "" }
      .bind(to: model.password)
      .dispose(in: bag)
    passwordField.reactive
      .controlEvents(.editingDidBegin) // .text fires additional events when tap button
      .map { _ in "" }
      .bind(to: passwordField.reactive.error)
      .dispose(in: bag)
    
    model.passwordError
      .filter { $0 != nil }
      .map { $0?.rawValue }
      .bind(to: passwordField.reactive.error)
      .dispose(in: bag)
    model.passwordError
      .filter { $0 != nil }
      .map { _ in "" }
      .bind(to: passwordField.reactive.text)
      .dispose(in: bag)
    
    
    signInButton.reactive.tap.with(weak: view).observeNext { view in // should be before signInAction [passwordValidation --> passwordCheck]
      view.endEditing(true)
    }.dispose(in: bag)
    signInButton.reactive.tap.bind(to: model.signInAction).dispose(in: bag)
    
    restoreKeyButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
      }.dispose(in: bag)
    restoreKeyButton.reactive.tap.bind(to: model.restoreKeyAction).dispose(in: bag)
    
    goToViewAction.observeNext { [weak self] name, context in
      let vc = try! self?.viewController(for: .named(name: name), context: context)
      self?.navigationController?.pushViewController(vc!, animated: true)
    }.dispose(in: bag)
    
    navigationController?.isToolbarHidden = true
  }
  
  // MARK: Default values
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}

extension SignInViewController: ContextSubject {
  func apply(context: RouterContextProtocol) {
    let appCtx = context.get(context: ApplicationContext.self)!
    self.model = SignInViewModel(walletService: appCtx.walletService)
  }
}
