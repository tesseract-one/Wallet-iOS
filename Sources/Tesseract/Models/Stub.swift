//
//  Stub.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/6/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class Stub {
  var accounts: [Account]
  var tokens: [Token]
  var apps: [App]
  
  init () {
    let icon = UIImage(named: "logo")
    let cardBackground = UIImage(named: "card-total")
    
//    let cardanoIcon = UIImage(named: "token-cardano")
    let ethereumIcon = UIImage(named: "token-ethereum")
    let stellarIcon = UIImage(named: "token-stellar")
    
    let account1 = Account("Main", 120.04, 11.5, icon)!
    let account2 = Account("Bonus", 40.24, 3.25, icon)!
    let account3 = Account("Additional", 20.35, -1.04, icon)!
    let account4 = Account("Extra", 12.424, -6.22, icon)!
    
    accounts = [account1, account2, account3, account4]
    
    let token1 = Token("Ethereum", "ETH", ethereumIcon, cardBackground, 100)!
    let token2 = Token("Bitcoin", "BTC", icon, cardBackground, 4200)!
    let token3 = Token("Colu", "CLN", icon, cardBackground, 3.456)!
    let token4 = Token("Stellar", "XLM", stellarIcon, cardBackground, 35.6)!
    let token5 = Token("Coul Cousin", "CUZ", icon, cardBackground, 0.34)!
    let token6 = Token("Storj", "STORJ", icon, cardBackground, 4.21)!
    let token7 = Token("EOS", "EOS", icon, cardBackground, 54.21)!
    
    tokens = [token1, token2, token3, token4, token5, token6, token7]

    let app1 = App("Cool Cousin", icon, token5, accounts)!
    let app2 = App("Colu", icon, token3, [accounts[1], accounts[2]])!
    let app3 = App("Storj", icon, token6, [accounts[0]])!
    let app4 = App("Deos Games", icon, token3, [accounts[3]])!
    let app5 = App("EOS Knights", icon, token7, [accounts[2]])!
    let app6 = App("DopeRaider", icon, token2, [accounts[2], accounts[3]])!
    let app7 = App("CryptoKitties", icon, token1, [accounts[1], accounts[0]])!
    let app8 = App("Stellar", icon, token4, [accounts[2], accounts[3]])!
    let app9 = App("CryptoZombies", icon, token1, [accounts[1], accounts[0]])!
    
    apps = [app1, app2, app3, app4, app5, app6, app7, app8, app9]
  
  }
}
