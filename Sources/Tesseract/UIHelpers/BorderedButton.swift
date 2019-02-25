//
//  BorderedButton.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/12/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class BorderedButton: UIButton {
  
//  @IBInspectable override var borderColor: UIColor? = UIColor.clear {
//    didSet {
//      layer.borderColor = self.borderColor?.cgColor
//    }
//  }
  
  @IBInspectable var borderWidth: CGFloat = 0.0 {
    didSet {
      layer.borderWidth = self.borderWidth
    }
  }
  
  @IBInspectable var roundedByHeight: Bool = false
  
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
    didSet {
      if !roundedByHeight {
        layer.cornerRadius = self.cornerRadius
      } else {
        layer.cornerRadius = self.frame.height / 2.0
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  override var isEnabled: Bool {
    willSet {
      self.alpha = !newValue ? 0.5 : 1.0
    }
  }
  
  override var bounds: CGRect {
    get {
      return super.bounds
    }
    set (newFrame) {
      super.bounds = newFrame
      self.layer.cornerRadius = roundedByHeight ? newFrame.height / 2 : self.cornerRadius
    }
  }
}


class BorderedClippedButton: BorderedButton {
  @IBInspectable override var roundedByHeight: Bool {
    didSet {
      layer.masksToBounds = self.cornerRadius > 0
    }
  }
  
  @IBInspectable override var cornerRadius: CGFloat {
    didSet {
      if !roundedByHeight {
        layer.cornerRadius = self.cornerRadius
        layer.masksToBounds = self.cornerRadius > 0
      } else {
        layer.cornerRadius = self.frame.height / 2.0
        layer.masksToBounds = true
      }
    }
  }
}

