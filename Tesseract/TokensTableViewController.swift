//
//  TokensTableViewController.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class TokensTableViewController: AssetsTemplateTableViewController<Token, TokensTableViewCell> {
  
  override func loadAssets() {
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

    assets += [token1, token2, token3, token4, token5]
  }
}
