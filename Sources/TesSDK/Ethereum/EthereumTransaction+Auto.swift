//
//  EthereumTransaction+Auto.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import Web3
import PromiseKit

extension EthereumTransaction {
    func autononce(web3: Web3) -> Promise<EthereumTransaction> {
        guard let from = self.from else {
            return Promise(error: EthereumSignProviderError.mandatoryFieldMissing("from"))
        }
        
        guard self.nonce == nil else {
            return Promise.value(self)
        }
        
        var tx = self
        
        return web3.eth.getTransactionCount(address: from, block: .pending)
            .map {
                tx.nonce = $0
                return tx
        }
    }
    
    func autogas(web3: Web3) -> Promise<EthereumTransaction> {
        guard self.gas == nil else {
            return Promise.value(self)
        }
        
        var tx = self
        
        do {
            return web3.eth.estimateGas(call: try tx.toCall())
                .map {
                    tx.gas = $0
                    return tx
            }
        } catch let e {
            return Promise(error: e)
        }
    }
    
    func toCall() throws -> EthereumCall {
        guard let to = self.to else {
            throw EthereumSignProviderError.mandatoryFieldMissing("to")
        }
        
        return EthereumCall(from: self.from, to: to, gas: self.gas, gasPrice: self.gasPrice, value: self.value, data: self.data)
    }
}
