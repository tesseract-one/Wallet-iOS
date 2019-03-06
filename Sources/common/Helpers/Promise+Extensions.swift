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
    var signal : ResultSignal<T, AnyError> {
        return ResultSignal<T, AnyError> { observer in
            self
                .done { observer.completed(with: .success($0)) }
                .catch { observer.completed(with: .failure(AnyError($0))) }
            return observer.disposable
        }
    }
}
