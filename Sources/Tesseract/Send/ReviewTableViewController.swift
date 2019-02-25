//
//  ReviewTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class ReviewTableViewController: UITableViewController {

  // MARK: Outlets
  //
  @IBOutlet weak var fromLabel: UILabel!
  @IBOutlet weak var toLabel: UILabel!
  @IBOutlet weak var coinLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  @IBOutlet weak var totalLabel: UILabel!
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  // Default height of 1st section is higher than 38 (idk why)
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 38.0
  }
  
  // MARK: Private functions
  //
  func setUp() {
    fromLabel.text = "Work Account (0x23131…a350a)"
    toLabel.text = "0x2313…123b"
    coinLabel.text = "Ethereum (ETH)"
    amountLabel.text = "1 ETH ($200.72)"
    totalLabel.text = "1.05 ETH ($210.76)"
  }

}
