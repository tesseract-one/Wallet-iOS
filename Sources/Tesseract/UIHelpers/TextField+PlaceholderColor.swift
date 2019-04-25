//
//  TextField+PlaceholderColor.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/12/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(
                string:self.placeholder != nil ? self.placeholder! : "", attributes:[.foregroundColor: newValue!]
            )
        }
    }
}
