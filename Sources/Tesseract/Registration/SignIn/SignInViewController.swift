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

class SignInViewController: UIViewController {
  
  private var viewModel: SignInViewModelProtocol = SignInViewModel()
  
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
      .bind(to: viewModel.password)
      .dispose(in: bag)
    passwordField.reactive
      .controlEvents(.editingDidBegin) // .text fires additional events when tap button
      .with(weak: passwordField)
      .observeNext { passwordField in
        passwordField.error = ""
        passwordField.text = ""
      }.dispose(in: bag)
    
    viewModel.passwordError
      .filter{$0 != nil}
      .with(weak: passwordField)
      .observeNext { passwordError, passwordField in
        passwordField.error = passwordError
      }.dispose(in: bag)
    
    signInButton.reactive.tap.with(weak: view).observeNext { view in // should be before signInAction [passwordValidation --> passwordCheck]
      view.endEditing(true)
    }.dispose(in: bag)
    signInButton.reactive.tap.bind(to: viewModel.signInAction).dispose(in: bag)
    
    restoreKeyButton.reactive.tap.with(weak: view).observeNext { view in
      view.endEditing(true)
      }.dispose(in: bag)
    restoreKeyButton.reactive.tap.bind(to: viewModel.restoreKeyAction).dispose(in: bag)
    
    navigationController?.isToolbarHidden = true
  }
  
  // MARK: Default values
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}
