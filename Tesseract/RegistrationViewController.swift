//
//  RegistrationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/8/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
  
  // MARK: Outlets
  //
  @IBOutlet weak var createKeyButton: UIButton!
  @IBOutlet weak var restoreKeyButton: UIButton!
  
  @IBOutlet weak var yourPasswordField: NextResponderTextField!
  @IBOutlet weak var confirmPasswordField: NextResponderTextField!
  
  // MARK: Lifecycle hooks
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    yourPasswordField.isPlaceholderUppercasedWhenEditing = true
    yourPasswordField.placeholderActiveColor = UIColor.white
    yourPasswordField.placeholderNormalColor = UIColor.white
    yourPasswordField.placeholderLabel.fontSize = 25
    yourPasswordField.dividerColor = UIColor.white
    yourPasswordField.dividerActiveColor = UIColor.white
    yourPasswordField.dividerNormalColor = UIColor.white
    yourPasswordField.textColor = UIColor.white
    yourPasswordField.font = UIFont.systemFont(ofSize: 25)
    yourPasswordField.isClearIconButtonEnabled = true
    yourPasswordField.isClearIconButtonAutoHandled = true
    yourPasswordField.clearIconButton?.tintColor = UIColor.white
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
    print("Created Key")
  }
  
  @IBAction func restoreKey(_ sender: UIButton) {
    print("Restore Key")
  }
  
  
  // MARK: Private functions
  //
}
