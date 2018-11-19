//
//  MnemonicsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class MnemonicsViewController: UIViewController {
  
  // MARK: Properties
  //
  let mnemonic: String = "we have all heard how crucial it is to set intentions goals and targets"
  
  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicsTextView: UITextView!

  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  // MARK: Actions
  //
  @IBAction func doneWithMnemonic(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowMnemonicsVerification", sender: self)
  }
  
  // MARK: Private functions
  //
  private func setUp() {
    // Set up TextView
    mnemonicsTextView.text = mnemonic
  }
}
