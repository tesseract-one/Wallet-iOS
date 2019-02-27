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
