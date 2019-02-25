//
//  Asset.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation

class Asset {
  
  //MARK: Properties
  //
  var name: String
  
  //MARK: Initialization
  //
  init?(_ name: String) {
    
    guard !name.isEmpty else {
      return nil
    }
  
    self.name = name
  }
}
