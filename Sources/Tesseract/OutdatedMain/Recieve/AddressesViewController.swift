//
//  AddressesViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/26/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AddressesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  // MARK: Outlets
  //
  @IBOutlet weak var addressesTableView: UITableView!
  
  // MARK: Properties
  //
  var addresses = [(address: String, balance: String)]()
  
  // MARK: Lifecyce
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addressesTableView.delegate = self
    addressesTableView.dataSource = self
    
    loadAddresses()
  }
  
  // MARK: Default values
  // Make the Status Bar Light/Dark Content for this View
  override var preferredStatusBarStyle : UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
  
  // MARK: - Table view data source
  //
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return addresses.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Table view cells are reused and should be dequeued using a cell identifier.
    let cellIdentifier = "AddressesTableViewCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AddressesTableViewCell else {
      fatalError("The dequeued cell is not an instance of AddressesTableViewCell.")
    }
    
    // Fetches the appropriate coin for the data source layout.
    let address = addresses[indexPath.row]
    
    cell.addressLabel.text = address.address
    cell.balanceLabel.text = address.balance
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 38))
    header.backgroundColor = UIColor.init(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    
    let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 14, width: tableView.frame.width - 32, height: 18))
    label.text = "ADDRESSES"
    label.sizeToFit()
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .gray
    
    header.addSubview(label)
    
    return header
  }
  
  // MARK: Actions
  //
  @IBAction func cancel(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: Private Methods
  //
  private func loadAddresses() {
    addresses = [
      ("0x742d35cc6634c0532925a3b844bc454e4438f44e", "1.645 ETH"),
      ("0x742d35cc6634c0532925a3b844bc454e4438f44e", "322 ETH"),
      ("0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", "228 ETH"),
      ("0x281055afc982d96fab65b3a49cac8b878184cb16", "34 ETH"),
      ("0x6f46cf5569aefa1acc1009290c8e043747172d89", "33 ETH"),
      ("0x90e63c3d53e0ea496845b7a03ec7548b70014a91", "0 ETH"),
      ("0x53d284357ec70ce289d6d64134dfac8e511c8a3d", "0 ETH"),
      ("0xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98", "0 ETH"),
      ("0x61edcdf5bb737adffe5043706e7c5bb1f1a56eea", "0 ETH"),
      ("0xab7c74abc0c4d48d1bdad5dcb26153fc8780f83e", "0 ETH"),
      ("0xbe0eb53f46cd790cd13851d5eff43d12404d33e8", "0 ETH")
    ]
  }

}
