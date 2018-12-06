//
//  AppsTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class AppsTableViewCell: AssetsTemplateTableViewCell<App> {
  
  //MARK: Properties
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var accountsLabel: UILabel!
  @IBOutlet weak var appImageView: UIImageView!
  
  // MARK: Override functions
  //
  override func setUp(_ app: App) {
    asset = app
    
    nameLabel.text = app.name
    accountsLabel.text = "\(app.accounts.count) accounts"
    appImageView.image = app.icon
  }
  
  override func addAssets() {
    guard let app = self.asset else {
      fatalError("App is missed in AppsTableViewCell")
    }
    
    let accounts = app.accounts
    
    guard accounts.count > 0 else {
      return
    }
    
    let stackViewHeightValue = CGFloat(appCellHeight * Double(accounts.count))
    
    stackViewHeight?.isActive = false
    stackViewHeight = stackView?.heightAnchor.constraint(equalToConstant: stackViewHeightValue)
    stackViewHeight?.isActive = true
    
    extendedHeight = stackViewHeightValue + 60
    
    for account in accounts {
      addAssetSubView(account.name, account.balance, app.abbreviation)
    }
  }
}
