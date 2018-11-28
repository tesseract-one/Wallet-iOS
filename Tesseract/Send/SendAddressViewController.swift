//
//  SendAddressViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/26/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class SendAddressViewController: UIViewController {
  
  // MARK: Outlets
  //
  @IBOutlet weak var addressTextView: NextResponderTextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: Actions
  //
  @IBAction func next(_ sender: UIButton) {
    view.endEditing(true)
    
    guard let address = addressTextView.text, address != "" else {
      addressTextView.error = "Enter address!"
      addressTextView.textViewDidChange(addressTextView)
      return
    }
    
    performSegue(withIdentifier: "ShowSendAmount", sender: self)
  }
  
  @IBAction func scan(_ sender: UIButton) {
    print("SCAN")
  }
    
}
