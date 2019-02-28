//
//  TokensTableViewCell.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/30/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TokensTableViewCell: AssetsTemplateTableViewCell<TokenAsset> {

  //MARK: Properties
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var balanceUSDLabel: UILabel!
  @IBOutlet weak var balanceUpdateLabel: UILabel!
  @IBOutlet weak var tokenImageView: UIImageView!
  
  // MARK: Override functions
  //
  override func setUp(_ token: TokenAsset) {
    asset = token
    
    nameLabel.text = token.name
    balanceLabel.text = "\(String(token.balance)) \(token.abbreviation)"
    balanceUSDLabel.text = "$\(String(Double(token.balance * token.price).rounded(toPlaces: 2)))"
    tokenImageView.image = token.icon
    
    let tokenBalanceUpdateText = "\(String(Double(token.balanceUpdate).rounded(toPlaces: 2))) \(token.abbreviation)"
    
    if token.balanceUpdate <= 0.0 {
      balanceUpdateLabel.text = tokenBalanceUpdateText
    } else {
      balanceUpdateLabel.text = "+\(tokenBalanceUpdateText)"
    }
  }

  override func addAssets() {
    guard let token = self.asset else {
      fatalError("Token is missed in TokensTableViewCell")
    }
    
    let apps = token.apps
    
    guard apps.count > 0 else {
      return
    }
    
    let stackViewHeightValue = CGFloat(apps.count >= 4 ? appCellHeight * 4 : appCellHeight * Double(apps.count))
    
    stackViewHeight?.isActive = false
    stackViewHeight = stackView?.heightAnchor.constraint(equalToConstant: stackViewHeightValue)
    stackViewHeight?.isActive = true
    
    extendedHeight = stackViewHeightValue + 60
    
    let shownApps = apps.prefix(3)
    
    for app in shownApps {
      addAssetSubView(app.name, app.balance, token.abbreviation)
    }
    
    if apps.count > 3 {
      let hiddenApps = apps[3...]
      let hiddenAppsBalance = hiddenApps.reduce(0, { (acc, hiddenApp) -> Double in
        acc + hiddenApp.balance
      })
      
      addAssetSubView("…and \(hiddenApps.count) more Apps", hiddenAppsBalance, token.abbreviation)
    }
  }
}