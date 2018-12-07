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
    
    let account1 = Account("Main", 120.04, 11.5)!
    let account2 = Account("Bonus", 40.24, 3.25)!
    let account3 = Account("Additional", 20.35, -1.04)!
    let account4 = Account("Extra", 12.424, -6.22)!
    
    accounts = [account1, account2, account3, account4]
    
    let token1 = Token(name: "Ethereum", abbreviation: "ETH", icon: icon, price: 100)!
    let token2 = Token(name: "Bitcoin", abbreviation: "BTC", icon: icon, price: 4200)!
    let token3 = Token(name: "Colu", abbreviation: "CLN", icon: icon, price: 3.456)!
    let token4 = Token(name: "Stellar", abbreviation: "XLM", icon: icon, price: 35.6)!
    let token5 = Token(name: "Coul Cousin", abbreviation: "CUZ", icon: icon, price: 0.34)!
    let token6 = Token(name: "Storj", abbreviation: "STORJ", icon: icon, price: 4.21)!
    let token7 = Token(name: "EOS", abbreviation: "EOS", icon: icon, price: 54.21)!
    
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
