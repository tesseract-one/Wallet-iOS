//
//  ReviewSendTransactionViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/4/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ReviewSendTransactionViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var sentAmount: UILabel!
    @IBOutlet weak var sentAmountInUSD: UILabel!
    @IBOutlet weak var recieveAmount: UILabel!
    @IBOutlet weak var recieveAmountInUSD: UILabel!
    @IBOutlet weak var gasAmount: UILabel!
    @IBOutlet weak var gasAmountInUSD: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Default values
    // Make the Status Bar Light/Dark Content for this View
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}
