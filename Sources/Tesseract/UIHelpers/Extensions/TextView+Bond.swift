//
//  TextView+Bond.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//


#if os(iOS) || os(tvOS)

import UIKit
import ReactiveKit
import Bond

extension ReactiveExtensions where Base: TextView {
    func notification(_ type: UITextViewReactiveExtensionsNotificationType) -> SafeSignal<UITextView> {
        return base.textView.reactive.notification(type)
    }
    
    var error: Bond<String> {
        return bond { textView, text in
            textView.error = text
        }
    }
}

#endif
