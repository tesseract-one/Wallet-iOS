//
//  Result+Promise.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/26/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import PromiseKit

public extension Result {
    public var promise: Promise<T> {
        switch self {
        case .fulfilled(let val):
            return Promise.value(val)
        case .rejected(let err):
            return Promise(error: err)
        }
    }
}

public extension CatchMixin {
    public func mapError<T>(on: DispatchQueue? = conf.Q.map, flags: DispatchWorkItemFlags? = nil, policy: CatchPolicy = conf.catchPolicy, _ body: @escaping(Error) -> Error) -> Promise<T> where Self.T == T {
        return recover(on: on, flags: flags, policy: policy) { Promise(error: body($0)) }
    }
}
