//
//  MaterialTextField+Bond.swift
//  Tesseract
//
//  Created by Yura Kulynych on 4/16/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Bond
import ReactiveKit

extension ReactiveExtensions where Base: MaterialTextField {
    var error: Bond<String> {
        return bond { field, text in
            field.error = text
        }
    }
}
