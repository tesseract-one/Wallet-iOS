//
//  ErrorTextField+Bind.swift
//  Tesseract
//
//  Created by Yura Kulynych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Bond
import ReactiveKit
import MaterialTextField

private class TextError: NSError {
    init(_ text: String) {
        super.init(domain: "Tesseract", code: 0, userInfo: [NSLocalizedDescriptionKey: text])
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static let noError = TextError("")
}

extension ReactiveExtensions where Base: MFTextField {
    var error: Bond<String?> {
        return bond { field, text in
            field.setError(text != nil ? TextError(text!) : TextError.noError, animated: true)
        }
    }
}
