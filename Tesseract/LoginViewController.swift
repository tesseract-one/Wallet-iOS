//
//  LoginViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/21/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

  // MARK: Properties
  //
  let password: String = "qweqweqwe"
  
  // MARK: Outlets
  //
  @IBOutlet weak var passwordField: NextResponderTextField!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.isToolbarHidden = true
  }
  
  // MARK: Default values
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  // MARK: Actions
  //
  @IBAction func signIn(_ sender: UIButton) {
    view.endEditing(true)
    
    if passwordField.text != password {
      passwordField.text = ""
      passwordField.error = "Wrong password!"
    } else {
      performSegue(withIdentifier: "ShowHome", sender: self)
    }
  }
  
  @IBAction func restoreKey(_ sender: UIButton) {
    view.endEditing(true)
    print("Restore Key")
  }
}
