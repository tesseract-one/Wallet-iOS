//
//  CustomInsetsTextView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/19/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

open class CustomInsetsTextView: UITextView {
  
  // MARK: Inspectable vars
  //
  @IBInspectable
  open var leftInset: CGFloat = 16 {
    didSet {
      updateInsets()
    }
  }
  
  @IBInspectable
  open var topInset: CGFloat = 16 {
    didSet {
      updateInsets()
    }
  }
  
  @IBInspectable
  open var rightInset: CGFloat = 16 {
    didSet {
      updateInsets()
    }
  }
  
  @IBInspectable
  open var bottomInset: CGFloat = 16 {
    didSet {
      updateInsets()
    }
  }
  
  // MARK: Lifecycle
  //
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    updateInsets()
  }
  
  // Private methods
  //
  private func updateInsets() {
    textContainerInset = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
  }
}

class ShadowedTextView: CustomInsetsTextView {
  
  // MARK: Inspectable vars
  //
  @IBInspectable
  var shadowOpacity: Float {
    get {
      return self.layer.shadowOpacity
    }
    set {
      layer.shadowOpacity = newValue
    }
  }
  
  @IBInspectable
  var shadowOffset: CGSize {
    get {
      return layer.shadowOffset
    }
    set {
      layer.shadowOffset = newValue
    }
  }
  
  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowRadius = newValue
    }
  }
  
  @IBInspectable
  var shadowColorIB: UIColor? {
    get {
      if let color = layer.shadowColor {
        return UIColor(cgColor: color)
      }
      return nil
    }
    set {
      if let color = newValue {
        layer.shadowColor = color.cgColor
      } else {
        layer.shadowColor = nil
      }
    }
  }
  
  // MARK: Lifecycle
  //
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    layer.masksToBounds = false
  }
}
