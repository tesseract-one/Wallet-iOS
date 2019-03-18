//
//  Web3+EIP712TypedData.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/19/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import Web3

extension EthereumTypedData {
    public var eip712TypedData: EIP712TypedData {
        return EIP712TypedData(
            primaryType: primaryType,
            types: types.mapValues{$0.map{$0.eip712Type}},
            domain: domain.eip712Domain,
            message: message
        )
    }
}

extension EthereumTypedData.Domain {
    var eip712Domain: EIP712TypedData.Domain {
        return EIP712TypedData.Domain(
            name: name,
            version: version,
            chainId: chainId,
            verifyingContract: verifyingContract.tesseract
        )
    }
}

extension EthereumTypedData._Type {
    var eip712Type: EIP712TypedData._Type {
        return EIP712TypedData._Type(name: name, type: type)
    }
}

extension JSONValue: SerializableValueEncodable {
    public var serializable: SerializableValue {
        switch self {
        case .null: return .nil
        case .bool(let bool): return .bool(bool)
        case .number(let num): return .float(num)
        case .string(let str): return .string(str)
        case .array(let arr): return .array(arr.map{$0.serializable})
        case .object(let obj): return .object(obj.mapValues{$0.serializable})
        }
    }
}
