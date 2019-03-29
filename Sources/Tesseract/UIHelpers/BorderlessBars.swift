//
//  BorderlessBars.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/16/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class BorderlessNavigationBar: UINavigationBar {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    sharedSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    sharedSetup()
  }
  
  private func sharedSetup() {
    shadowImage = UIImage.init()
  }
}

class BorderlessTabBar: UITabBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    private func sharedSetup() {
        shadowImage = UIImage()
        backgroundImage = UIImage()
    }
}
