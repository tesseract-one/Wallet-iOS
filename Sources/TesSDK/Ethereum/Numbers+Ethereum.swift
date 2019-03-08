//
//  BigInt+Ethereum.swift
//  TesSDK
//
//  Created by Yura Kulynych on 3/8/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import BigInt
import Web3

extension BigUInt {
    public func ethValue(precision: UInt = 6) -> Double {
        return Double(self / BigUInt(pow(10.0, Double(18 - precision)))) / pow(10.0, Double(precision))
    }
}

extension BigInt {
    public func ethValue(precision: UInt = 6) -> Double {
        return Double(self / BigInt(pow(10.0, Double(18 - precision)))) / pow(10.0, Double(precision))
    }
}

extension EthereumQuantity {
    public func ethValue(precision: UInt = 6) -> Double {
        return quantity.ethValue(precision: precision)
    }
}
