//
//  Token.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/28/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class Token {
  
  //MARK: Properties
  //
  var name: String
  var abbreviation: String
  var icon: UIImage?
  var price: Double
  
  //MARK: Initialization
  //
  init?(name: String, abbreviation: String, icon: UIImage?, price: Double) {
    
    guard !name.isEmpty else {
      return nil
    }
    
    guard !abbreviation.isEmpty else {
      return nil
    }
    
    guard price >= 0 else {
      return nil
    }
    
    self.name = name
    self.abbreviation = abbreviation
    self.icon = icon
    self.price = price
  }

}
