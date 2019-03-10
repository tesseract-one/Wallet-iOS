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
    
    public func sign(data: EthereumData, account: EthereumAddress? = nil) -> Promise<EthereumData> {
        let accAddr = account != nil ? account!.hex(eip55: false) : signProvider.account
        if let addr = accAddr {
            return signProvider.sign
                .eth_signData(account: addr, data: Data(data.bytes))
                .map{try EthereumData(bytes: $0)}
        }
        return Promise(error: EthereumSignProviderError.emptyAccount)
    }
    
    public func signTransaction(tx: EthereumTransaction) -> Promise<EthereumSignedTransaction> {
        return signProvider.sign.eth_signTx(tx: tx, chainId: signProvider.chainId)
    }
}

extension Web3 {
    public var personal: EthereumPersonal {
        return EthereumPersonal(signProvider: self.provider as! EthereumSignWeb3Provider)
    }
}
