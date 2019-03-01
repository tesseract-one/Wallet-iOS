//
//  ErrorTextView+Bind.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/1/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Bond
import ReactiveKit
import Material

extension ReactiveExtensions where Base: NextResponderTextView {
  var error: Bond<String?> {
    return bond { errorView, text in
      errorView.error = text
    }
  }
}
