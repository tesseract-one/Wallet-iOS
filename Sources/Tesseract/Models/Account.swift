//
//  File.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/6/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class Account {
  
  //MARK: Properties
  //
  var name: String
  var balance: Double
  var balanceUpdate: Double
  var icon: UIImage?
  
  //MARK: Initialization
  //
  init?(_ name: String, _ balance: Double, _ balanceUpdate: Double?, _ icon: UIImage?) {
    
    guard !name.isEmpty else {
      return nil
    }
    
    guard balance >= 0 else {
      return nil
    }
    
    self.name = name
    self.balance = balance
    self.balanceUpdate = balanceUpdate ?? 0
    self.icon = icon
  }
}
