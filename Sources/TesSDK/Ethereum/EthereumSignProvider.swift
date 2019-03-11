//
//  EthereumSignProvider.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Web3

public enum EthereumSignProviderError: Error {
    case accountDoesNotExist(String)
    case emptyAccount
    case mandatoryFieldMissing(String)
    case emptyResponse(String)
}

public protocol EthereumSignProvider: SignProvider {
    func eth_accounts(networkId: UInt64) -> Promise<Array<String>>
    func eth_signTx(tx: EthereumTransaction, networkId: UInt64, chainId: UInt64) -> Promise<EthereumSignedTransaction>
//    func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool>
    func eth_signData(account: String, data: Data, networkId: UInt64) -> Promise<Data>
    //func eth_signTypedData(account: String) -> Promise<Array<UInt8>>
}
