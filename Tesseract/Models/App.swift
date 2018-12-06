//
//  App.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class App: Asset {
  
  //MARK: Properties
  //
  var abbreviation: String
  var icon: UIImage?
  var accounts: [(name: String, balance: Double)]
  
  //MARK: Initialization
  //
  init?(_ name: String, _ abbreviation: String, _ icon: UIImage?, _ accounts: [(name: String, balance: Double)]) {
    
    guard !abbreviation.isEmpty else {
      return nil
    }
    
    self.abbreviation = abbreviation
    self.icon = icon
    self.accounts = accounts
    
    super.init(name)
  }
}
