//
//  UIViewController+KeyboardDismiss.swift
//  Tesseract
//
//  Created by Yura Kulynych on 3/24/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import UIKit
import ReactiveKit

extension UIViewController {
    public func setupKeyboardDismiss() {
        view.reactive.tapGesture()
            .map { tap in
                tap.cancelsTouchesInView = false
                return
            }
            .with(weak: view)
            .observeNext { $0.endEditing(true)}
            .dispose(in: reactive.bag)
    }
}
