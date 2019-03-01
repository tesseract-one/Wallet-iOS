//
//  ReviewViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
  
  // MARK: Outlets
  //
  @IBOutlet weak var passwordTextfield: UITextField!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Actions
  //
  @IBAction func send(_ sender: UIButton) {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
}
