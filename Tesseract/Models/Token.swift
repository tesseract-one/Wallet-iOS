//
//  Token.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class Token: Coin {
  
  //MARK: Properties
  //
  var price: Double
  var balanceUpdate: Double?
  var apps: [(name: String, balance: Double)]
  
  //MARK: Initialization
  //
  init?(name: String, abbreviation: String, icon: UIImage?, price: Double, balanceUpdate: Double?, apps: [(name: String, balance: Double)]) {
    
    guard price >= 0 else {
      return nil
    }
    
    self.price = price
    self.balanceUpdate = balanceUpdate ?? 0
    
    let balance = apps.reduce(0, { (acc, app) -> Double? in
      guard app.balance >= 0 else {
        fatalError("App balance can't be less than 0. In app \(app.name)")
      }
      
      return acc! + app.balance
    })
    
    self.apps = apps
    
    super.init(name, abbreviation, balance!, icon)
  }

}
