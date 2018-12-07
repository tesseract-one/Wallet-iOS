//
//  TokensTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

struct TokenAsset: NamedAsset {
  var name: String
  var abbreviation: String
  var icon: UIImage?
  var price: Double
  var balance: Double
  var balanceUpdate: Double
  var apps: [( name: String, balance: Double )]
}

class TokensTableViewController: AssetsTemplateTableViewController<TokenAsset, TokensTableViewCell> {
  
  override func loadAssets() {
    assets  = AppState.shared.wallet?.stub.apps.reduce([], { (acc, app) -> [TokenAsset] in
      let appHaveTokenIndex = acc.firstIndex(where: { $0.name == app.token.name })
      
      if appHaveTokenIndex != nil {
        var acc = acc
        acc[appHaveTokenIndex!].balance += app.getBalance()
        acc[appHaveTokenIndex!].apps += [( app.name, app.getBalance() )]
        return acc
      }
      
      let tokenAsset = TokenAsset.init(
        name: app.token.name,
        abbreviation: app.token.abbreviation,
        icon: app.token.icon,
        price: app.token.price,
        balance: app.getBalance(),
        balanceUpdate: app.getBalanceUpdate(),
        apps: [( app.name, app.getBalance() )]
      )
      
      return acc + [tokenAsset]
    }) ?? []

  }
}
