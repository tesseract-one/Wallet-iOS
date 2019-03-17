//
//  Web3+EthereumTransaction.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/14/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import BigInt
import struct Web3.EthereumTransaction
import struct Web3.EthereumSignedTransaction
import struct Web3.EthereumQuantity
import struct Web3.EthereumData
import struct Web3.EthereumAddress

public typealias Web3EthereumTransaction = Web3.EthereumTransaction
public typealias Web3EthereumAddress = Web3.EthereumAddress

extension EthereumTransaction {
    public var web3: Web3EthereumTransaction {
        return Web3EthereumTransaction(
            nonce: Web3.EthereumQuantity(quantity: nonce),
            gasPrice: Web3.EthereumQuantity(quantity: gasPrice),
            gas: Web3.EthereumQuantity(quantity: gas),
            from: try! Web3EthereumAddress(rawAddress: from.rawValue.bytes), // Addresses are compatible
            to: to != nil ? try! Web3EthereumAddress(rawAddress: to!.rawValue.bytes) : nil,
            value: Web3.EthereumQuantity(quantity: value),
            data: Web3.EthereumData(raw: data.bytes)
        )
    }
}

extension Web3EthereumTransaction {
    public func tesseract() throws -> EthereumTransaction {
        guard let nonce = nonce, let gas = gas, let gasPrice = gasPrice, let from = from else {
            throw EthereumSignedTransaction.Error.transactionInvalid
        }
        let value = self.value ?? EthereumQuantity(integerLiteral: 0)
        return EthereumTransaction(
            nonce: nonce.quantity,
            gasPrice: gasPrice.quantity,
            gas: gas.quantity,
            from: try! EthereumAddress(rawAddress: Data(from.rawAddress)),
            to: to != nil ? try! EthereumAddress(rawAddress: Data(to!.rawAddress)) : nil,
            value: value.quantity,
            data: Data(data.bytes)
        )
    }
}

extension Web3.EthereumSignedTransaction {
    public init(tx: EthereumTransaction, signature: Data, chainId: BigUInt) throws {
        guard signature.count == 65 else {
            throw Web3.EthereumSignedTransaction.Error.signatureMalformed
        }
        var v = BigUInt(signature[64])
        if chainId > 0 {
            v += chainId * BigUInt(2) + BigUInt(8)
        }
        self.init(
            nonce: Web3.EthereumQuantity(quantity: tx.nonce),
            gasPrice: Web3.EthereumQuantity(quantity: tx.gasPrice),
            gasLimit: Web3.EthereumQuantity(quantity: tx.gas),
            to: tx.to != nil ? try Web3EthereumAddress(rawAddress: tx.to!.rawValue.bytes) : nil,
            value: Web3.EthereumQuantity(quantity: tx.value),
            data: Web3.EthereumData(raw: tx.data.bytes),
            v: Web3.EthereumQuantity(quantity: v),
            r: Web3.EthereumQuantity.bytes(signature[0..<32].bytes),
            s: Web3.EthereumQuantity.bytes(signature[32..<64].bytes),
            chainId: Web3.EthereumQuantity(quantity: chainId)
        )
    }
}

extension EthereumAddress {
    public var web3: Web3EthereumAddress {
        return try! Web3EthereumAddress(rawAddress: rawValue.bytes)
    }
}

extension Web3EthereumAddress {
    public var tesseract: EthereumAddress {
        return try! EthereumAddress(rawAddress: Data(rawAddress))
    }
}
