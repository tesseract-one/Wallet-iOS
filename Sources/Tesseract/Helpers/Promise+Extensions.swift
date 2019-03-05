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
    var signal : ResultSignal<T> {
        return ResultSignal<T> { observer in
            self
                .done { observer.completed(with: .fulfilled($0)) }
                .catch { observer.completed(with: .rejected($0)) }
            return observer.disposable
        }
    }
}

extension PromiseKit.Result {
    var value: T? {
        switch self {
        case .fulfilled(let val):
            return val
        default:
            return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .rejected(let err):
            return err
        default:
            return nil
        }
    }
    
    var isRejected: Bool {
        return !isFulfilled
    }
}


public typealias ResultSignal<T> = SafeSignal<PromiseKit.Result<T>>

extension ResultSignal {
    public static func fulfilled<T>(_ value: T) -> ResultSignal<T> {
        return ResultSignal.just(PromiseKit.Result.fulfilled(value))
    }
    
    public static func rejected<T>(_ error: Swift.Error) -> ResultSignal<T> {
        return ResultSignal.just(PromiseKit.Result.rejected(error))
    }
}
