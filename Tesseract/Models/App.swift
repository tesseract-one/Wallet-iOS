//
//  App.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class App {
  
  //MARK: Properties
  //
  var name: String
  var icon: UIImage?
  var token: Token
  var accounts: [Account] = []
  
  //MARK: Initialization
  //
  init?(_ name: String, _ icon: UIImage?, _ token: Token, _ accounts: [Account] ) {
    
    guard !name.isEmpty else {
      return nil
    }
    
    self.name = name
    self.icon = icon
    self.token = token
    self.accounts = accounts
  }
  
  // MARK: Public functions
  //
  public func getBalance() -> Double {
    return accounts.reduce(0, { (balance, account) -> Double? in
      guard account.balance >= 0 else {
        fatalError("Account balance can't be less than 0. In app \(account.name)")
      }
    
      return balance! + account.balance
    }) ?? 0
  }
  
  public func getBalanceUpdate() -> Double {
    return accounts.reduce(0, { (balanceUpdate, account) -> Double in
      return balanceUpdate + account.balanceUpdate
    })
  }
}
