//
//  TokensTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TokensTableViewController: UITableViewController, UISearchResultsUpdating {
  
  // MARK: Properties
  //
  var tokens = [Token]()
  var filteredTokens: [Token]?
  let tokenCellHeight: CGFloat = 60
  let searchController = UISearchController(searchResultsController: nil)
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadTokens()
    setUpSearchController()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .bottom)
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchController.dismiss(animated: false, completion: nil)
  }
  
  // MARK: - Table view data source
  //
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let tokens = filteredTokens else {
      return 0
    }
    return tokens.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Table view cells are reused and should be dequeued using a cell identifier.
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokensTableViewCell", for: indexPath) as? TokensTableViewCell else {
      fatalError("The dequeued cell is not an instance of TokensTableViewCell.")
    }
    
    // Fetches the appropriate token for the data source layout.
    if let filteredTokens = filteredTokens {
      let token = filteredTokens[indexPath.row]
      cell.setUp(token)
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let cell = tableView.cellForRow(at: indexPath) as? TokensTableViewCell
    return cell?.currentHeight ?? tokenCellHeight
  }
  
  // MARK: Serach controller
  //
  func updateSearchResults(for searchController: UISearchController) {
    if let searchText = searchController.searchBar.text, !searchText.isEmpty {
      filteredTokens = tokens.filter { token in
        return token.name.lowercased().contains(searchText.lowercased())
      }
    } else {
      filteredTokens = tokens
    }
    tableView.reloadData()
  }
  
  // MARK: Private Methods
  //
  private func loadTokens() {
    let icon = UIImage(named: "logo")
    let apps = [
      ("Wallet", 120.04),
      ("Alice", 40.24),
      ("Cryptocitties", 20.35),
      ("Golem", 12.424)
    ]
    
    let token1 = Token(name: "Ethereum", abbreviation: "ETH", icon: icon, price: 100, balanceUpdate: 0.65, apps: apps)!
    let token2 = Token(name: "Bitcoin", abbreviation: "BTC", icon: icon, price: 4200, balanceUpdate: 23, apps: [apps[1], apps[2]])!
    let token3 = Token(name: "Colu", abbreviation: "CLN", icon: icon, price: 3.456, balanceUpdate: 228, apps: [apps[0]])!
    let token4 = Token(name: "Stellar", abbreviation: "XLM", icon: icon, price: 35.6, balanceUpdate: -0.65, apps: [apps[3]])!
    let token5 = Token(name: "Coul Cousin", abbreviation: "CUZ", icon: icon, price: 0.34, balanceUpdate: 23.4, apps: [apps[2]])!

    tokens += [token1, token2, token3, token4, token5]
  }
  
  private func setUpSearchController() {
    filteredTokens = tokens
    
    searchController.searchResultsUpdater = self
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    
    searchController.searchBar.barStyle = .black
    searchController.searchBar.barTintColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
    searchController.searchBar.setTextFieldColor(color: UIColor(red:1, green:1, blue:1, alpha:0.05))
    
    tableView.tableHeaderView = searchController.searchBar
  }
}
