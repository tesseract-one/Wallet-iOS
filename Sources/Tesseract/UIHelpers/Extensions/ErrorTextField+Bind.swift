//
//  ErrorTextField+Bind.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Bond
import ReactiveKit
import Material

extension ReactiveExtensions where Base: ErrorTextField {
  var error: Bond<String?> {
    return bond { label, text in
      label.text = text
    }
  }
}
