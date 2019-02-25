//
//  MoreTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 1/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

struct MoreAccount {
  var name: String
  var balance: Double
}

class MoreTableViewController: UITableViewController {

  // MARK: Properties
  //
  var accounts = [MoreAccount]()
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadAccounts()
  }

  // MARK: - Table view data source
  //
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return accounts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Table view cells are reused and should be dequeued using a cell identifier.
    let cellIdentifier = "MoreTableViewCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MoreTableViewCell else {
      fatalError("The dequeued cell is not an instance of MoreTableViewCell.")
    }
    
    // Fetches the appropriate coin for the data source layout.
    let account = accounts[indexPath.row]
    
    cell.nameLabel.text = account.name
    cell.balanceLabel.text = "$\(String(account.balance))"
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 38))
    header.backgroundColor = UIColor.init(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    
    let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 14, width: tableView.frame.width - 32, height: 18))
    label.text = "ACCOUNTS"
    label.sizeToFit()
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .gray
    
    header.addSubview(label)
    
    return header
  }
  
  // MARK: Private functions
  //
  private func loadAccounts() {
    accounts = AppState.shared.wallet?.stub.accounts
      .map({ MoreAccount.init(name: $0.name, balance: $0.balance) }) ?? []
  }
}
