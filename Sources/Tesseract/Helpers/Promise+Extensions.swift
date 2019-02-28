//
//  Promise+Extensions.swift
//  Tesseract
//
//  Created by Yehor Popovych on 2/28/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import PromiseKit
import ReactiveKit

public extension Promise {
    var signal : Signal<T, AnyError> {
        return Signal<T, AnyError> { observer in
            self
                .done(observer.completed)
                .catch { observer.failed(AnyError($0)) }
            return observer.disposable
        }
    }
}
