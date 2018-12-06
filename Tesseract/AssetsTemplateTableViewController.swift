//
//  AssetsTemplateTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AssetsTemplateTableViewController<A: Asset, C: AssetsTemplateTableViewCell<A>>: UITableViewController, UISearchResultsUpdating {
  
  // MARK: Properties
  //
  var assets: [A] = [A]()
  var filteredAssets: [A]?
  let assetCellHeight: CGFloat = 60
  let searchController = UISearchController(searchResultsController: nil)
  
  // MARK: Lifecycle
  //
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadAssets()
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
    guard let assets = filteredAssets else {
      return 0
    }
    return assets.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    // Table view cells are reused and should be dequeued using a cell identifier.
    let cellIdentifier = NSStringFromClass(C.self).components(separatedBy: ".").last! as String
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? C else {
      fatalError("The dequeued cell is not an instance of \(cellIdentifier).")
    }
    
    // Fetches the appropriate asset for the data source layout.
    if let filteredAssets = filteredAssets {
      let asset = filteredAssets[indexPath.row]
      cell.setUp(asset)
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
    let cell = tableView.cellForRow(at: indexPath) as? C
    return cell?.currentHeight ?? assetCellHeight
  }
  
  // MARK: Serach controller
  //
  func updateSearchResults(for searchController: UISearchController) {
    if let searchText = searchController.searchBar.text, !searchText.isEmpty {
      filteredAssets = assets.filter { asset in
        return asset.name.lowercased().contains(searchText.lowercased())
      }
    } else {
      filteredAssets = assets
    }
    tableView.reloadData()
  }
  
  // MARK: Private Methods
  //
  private func setUpSearchController() {
    filteredAssets = assets
    
    searchController.searchResultsUpdater = self
    searchController.hidesNavigationBarDuringPresentation = false
    searchController.dimsBackgroundDuringPresentation = false
    
    searchController.searchBar.barStyle = .black
    searchController.searchBar.barTintColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
    searchController.searchBar.setTextFieldColor(color: UIColor(red:1, green:1, blue:1, alpha:0.05))
    
    tableView.tableHeaderView = searchController.searchBar
  }
  
  // MARK: Internal methods
  //
  internal func loadAssets() {
    preconditionFailure("this method needs to be overriden by concrete subscasses")
  }
}
