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
