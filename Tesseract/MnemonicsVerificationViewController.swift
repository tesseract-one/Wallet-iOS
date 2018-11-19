//
//  MnemonicsVerificationViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class MnemonicsVerificationViewController: UIViewController {
  
  // MARK: Properties
  //
  var mnemonic: String = ""
 
  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicsVerificationTextView: UITextView!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Navigation
  //
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    guard segue.destination is MnemonicsVerificationViewController else {
      fatalError("Unexpected destination: \(segue.destination)")
    }
    
    guard let mnemonicViewController = sender as? MnemonicsViewController  else {
      fatalError("Unexpected sender: \(String(describing: sender))")
    }
    
    mnemonic = mnemonicViewController.mnemonic
  }
  
  // MARK: Actions
  //
  @IBAction func doneWithMnemonicsVerification(_ sender: UIButton) {
    print("Done with Mnemonics Verification")
  }
  
  @IBAction func skipMnemonicsVerification(_ sender: UIButton) {
    print("Skip Mnemonics Verification")
  }
}
