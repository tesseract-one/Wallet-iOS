//
//  CardView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/6/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

class CardView: UIView {

  // MARK: Properties
  //
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var tokenNameLabel: UILabel!
  @IBOutlet weak var balanceLabel: UILabel!
  @IBOutlet weak var balanceUpdateLabel: UILabel!
  @IBOutlet weak var accountsStackView: UIStackView!
  @IBOutlet weak var accountsStackViewHeight: NSLayoutConstraint!
}
