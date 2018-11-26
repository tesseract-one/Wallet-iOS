//
//  RecieveCoinsViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/22/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class RecieveCoinsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  
  // MARK: Outlets
  //
  @IBOutlet weak var coinsTableView: UITableView!
  
  // MARK: Properties
  //
  var coins = [Coin]()

  override func viewDidLoad() {
    super.viewDidLoad()

    coinsTableView.delegate = self
    coinsTableView.dataSource = self
    
    loadCoins()
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return coins.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    // Table view cells are reused and should be dequeued using a cell identifier.
    let cellIdentifier = "RecieveCoinsTableViewCell"
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecieveCoinsTableViewCell else {
      fatalError("The dequeued cell is not an instance of RecieveCoinsTableViewCell.")
    }
    
    // Fetches the appropriate coin for the data source layout.
    let coin = coins[indexPath.row]

    cell.nameLabel.text = coin.name
    cell.balanceLabel.text = "\(String(coin.balance)) \(coin.abbreviation)"

    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 38))
    header.backgroundColor = UIColor.init(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
    
    let label: UILabel = UILabel.init(frame: CGRect(x: 16, y: 14, width: tableView.frame.width - 32, height: 18))
    label.text = "COIN"
    label.sizeToFit()
    label.font = UIFont.systemFont(ofSize: 13)
    label.textColor = .gray
    
    header.addSubview(label)
    
    return header
  }
  
  // MARK: Private Methods
  //
  private func loadCoins() {
    let coin1 = Coin(name: "Ethereum", abbreviation: "ETH", balance: 1.645, icon: nil)!
    let coin2 = Coin(name: "Cardano", abbreviation: "ADA", balance: 322, icon: nil)!
    let coin3 = Coin(name: "Bitcoin", abbreviation: "BTC", balance: 33.78, icon: nil)!
    let coin4 = Coin(name: "Colu", abbreviation: "CLN", balance: 621, icon: nil)!
    let coin5 = Coin(name: "EOS.IO", abbreviation: "EOS", balance: 82.821, icon: nil)!

    coins += [coin1, coin2, coin3, coin4, coin5]
  }
}
