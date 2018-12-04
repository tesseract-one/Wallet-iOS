//
//  Coin.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/22/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class Coin {

  //MARK: Properties
  //
  var name: String
  var abbreviation: String
  var balance: Double
  var icon: UIImage?

  //MARK: Initialization
  //
  init?(_ name: String, _ abbreviation: String, _ balance: Double, _ icon: UIImage?) {
    
    guard !name.isEmpty else {
      return nil
    }
    
    guard !abbreviation.isEmpty else {
      return nil
    }
    
    guard balance >= 0 else {
      return nil
    }
    
    self.name = name
    self.abbreviation = abbreviation
    self.balance = balance
    self.icon = icon
  }
}
