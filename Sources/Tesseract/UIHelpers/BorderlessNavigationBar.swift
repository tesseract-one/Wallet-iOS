//
//  BorderlessNavigationBar.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/16/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class BorderlessNavigationBar: UINavigationBar {
  
  // MARK: Lifecycle
  //
  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  // Private functions
  private func setUp() {
    shadowImage = UIImage.init()
  }
}
