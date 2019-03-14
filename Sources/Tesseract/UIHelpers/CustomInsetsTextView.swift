//
//  CustomInsetsTextView.swift
//  Tesseract
//
//  Created by Yura Kulynych on 11/19/18.
//  Copyright © 2018 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit

@IBDesignable
open class CustomInsetsTextView: UITextView {
  
  @IBInspectable
  open var insets: CGRect {
    get {
        return CGRect(x: textContainerInset.left, y: textContainerInset.top, width: textContainerInset.right, height: textContainerInset.bottom)
    }
    set (insets) {
        textContainerInset = UIEdgeInsets.init(top: insets.minY, left: insets.minX, bottom: insets.height, right: insets.width)
    }
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
