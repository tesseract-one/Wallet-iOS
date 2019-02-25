//
//  TermsOfServiceViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TermsOfServiceViewController: UIViewController {
  
  // MARK: Outlets
  @IBOutlet weak var termsTextView: UITextView!
  @IBOutlet weak var acceptButton: UIButton!
  
  // MARK: Lifecycle hooks
  //
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidLayoutSubviews() {
    termsTextView.setContentOffset(.zero, animated: false)
  }
  
  // MARK: Actions
  //
  @IBAction func agreeWithTerms(_ sender: UIButton) {
    performSegue(withIdentifier: "ShowMnemonics", sender: self)
  }
}
