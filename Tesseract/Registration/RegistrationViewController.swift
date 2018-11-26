//
//  RegistrationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/8/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

enum PasswordsErrorPhrases: String {
  case noPassword = "Please, enter password!"
  case differentPasswords = "Passwords are different!"
  case shortPasswords = "Passwords should be at least 8 symbols!"
}

class RegistrationViewController: UIViewController {
  
  // MARK: Properties
  //
  var password: String = ""
  
  // MARK: Outlets
  //  
  @IBOutlet weak var yourPasswordField: UITextField!
  @IBOutlet weak var confirmPasswordField: NextResponderTextField!
  
  // MARK: Lifecycle hooks
  //
  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  // MARK: Actions
  //
  @IBAction func creteKey(_ sender: UIButton) {
    view.endEditing(true)
    
    if validateTextFields() {
      password = yourPasswordField.text!
      performSegue(withIdentifier: "ShowTermsOfService", sender: self)
    }
  }
  
  @IBAction func restoreKey(_ sender: UIButton) {
    view.endEditing(true)
    print("Restore Key")
  }
  
  
  // MARK: Private functions
  //
  private func validateTextFields() -> Bool {
    // Check errors in one field
    guard yourPasswordField.text != "", let yourPassword = yourPasswordField.text else {
      confirmPasswordField.error = PasswordsErrorPhrases.noPassword.rawValue
      return false
    }
    
    guard confirmPasswordField.text != "", let confirmPassword = confirmPasswordField.text else {
      confirmPasswordField.error = PasswordsErrorPhrases.noPassword.rawValue
      return false
    }
    
    // Check errors in both fields
    if yourPassword != confirmPassword {
      confirmPasswordField.error = PasswordsErrorPhrases.differentPasswords.rawValue
    } else if yourPassword.count < 8 {
      confirmPasswordField.error = PasswordsErrorPhrases.shortPasswords.rawValue
    } else {
      return true
    }
    
    wipeTextFields()
    return false
  }
  
  private func wipeTextFields() {
    yourPasswordField.text = ""
    confirmPasswordField.text = ""
  }
}
