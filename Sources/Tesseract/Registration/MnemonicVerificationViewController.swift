//
//  MnemonicVerificationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class MnemonicVerificationViewController: UIViewController {
  
  // MARK: Properties
  //
  var mnemonic: String = ""
 
  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicVerificationTextView: NextResponderTextView!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Navigation
  //
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
  }
  
  // MARK: Actions
  //
  @IBAction func doneWithMnemonicVerification(_ sender: UIButton) {
    view.endEditing(true)

//    if mnemonic != mnemonicVerificationTextView.text {
//      mnemonicVerificationTextView.text = ""
//      mnemonicVerificationTextView.textViewDidChange(mnemonicsVerificationTextView)
//      mnemonicVerificationTextView.error = "Mnemonics are different!"
//    } else {
//      AppState.shared.unblockWallet()
//    }
  }
  
  @IBAction func skipMnemonicVerification(_ sender: UIButton) {
    AppState.shared.unblockWallet()
  }
}
