//
//  RoundedImage.swift
//  Tesseract
//
//  Created by Yura Kulynych on 12/5/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImage: UIImageView {
  
  @IBInspectable var roundedByHeight: Bool = false {
    didSet {
      layer.masksToBounds = self.cornerRadius > 0
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0.0 {
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
