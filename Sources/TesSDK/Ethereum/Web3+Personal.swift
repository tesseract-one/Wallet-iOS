//
//  Web3+Personal.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/10/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Web3

public struct EthereumPersonal {
    private let signProvider: EthereumSignWeb3Provider
    
    init(signProvider: EthereumSignWeb3Provider) {
        self.signProvider = signProvider
    }
    
    public func sign(data: EthereumData, account: Web3EthereumAddress? = nil) -> Promise<EthereumData> {
        if let acc = account ?? signProvider.account {
            return signProvider.sign
                .eth_signData(account: acc.tesseract, data: Data(data.bytes), networkId: signProvider.networkId)
                .map{try EthereumData(bytes: $0)}
        }
        return Promise(error: EthereumSignProviderError.emptyAccount)
    }
    
    public func signTransaction(tx: Web3EthereumTransaction) -> Promise<EthereumSignedTransaction> {
        return Promise()
            .map { try tx.tesseract() }
            .then { tx in
                self.signProvider.sign
                    .eth_signTx(tx: tx, networkId: self.signProvider.networkId, chainId: self.signProvider.chainId)
                    .map { (tx, $0) }
            }
            .map { tx, sig in try EthereumSignedTransaction(tx: tx, signature: sig, chainId: BigUInt(self.signProvider.chainId)) }
    }
}

extension Web3 {
    public var personal: EthereumPersonal {
        return EthereumPersonal(signProvider: self.provider as! EthereumSignWeb3Provider)
    }
}
