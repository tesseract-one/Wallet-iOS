//
//  MnemonicsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/15/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class MnemonicsViewController: UIViewController {
  
  // MARK: Outlets
  //
  @IBOutlet weak var mnemonicsTextView: UITextView!

  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  // MARK: Default values
  //
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  // MARK: Actions
  //
  @IBAction func doneWithMnemonic(_ sender: UIButton) {
    print("Done with Mnemonic")
  }
  
  // MARK: Private functions
  //
  private func setUp() {
    // Set up TextView
    mnemonicsTextView.text = "we have all heard how crucial it is to set intentions goals and targets"
    mnemonicsTextView.textContainerInset = .zero
    mnemonicsTextView.textContainer.lineFragmentPadding = 0
  }
}
