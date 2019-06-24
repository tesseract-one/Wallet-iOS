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
    var signal : ResultSignal<T, Swift.Error> {
        return ResultSignal<T, Swift.Error> { observer in
            self
                .done { observer.receive(lastElement: .success($0)) }
                .catch { observer.receive(lastElement: .failure($0)) }
            return observer.disposable
        }
    }
}
