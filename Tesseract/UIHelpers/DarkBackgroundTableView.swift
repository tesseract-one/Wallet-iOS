//
//  DarkBackgroundTableView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/4/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class DarkBackgroundTableView: UITableView {

  // MARK: Lifecycle
  //
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
    setUp()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  // Private functions
  private func setUp() {
    let bgView = UIView()
    bgView.backgroundColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
    backgroundView = bgView
  }
}
