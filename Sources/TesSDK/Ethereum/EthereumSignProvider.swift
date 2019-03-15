//
//  EthereumSignProvider.swift
//  Tesseract
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit

public enum EthereumSignProviderError: Error {
    case accountDoesNotExist(EthereumAddress)
    case emptyAccount
    case mandatoryFieldMissing(String)
    case emptyResponse(String)
    case nonIntNetworkVersion(String)
}

public protocol EthereumSignProvider: SignProvider {
    func eth_accounts(networkId: UInt64) -> Promise<Array<EthereumAddress>>
    func eth_signTx(tx: EthereumTransaction, networkId: UInt64, chainId: UInt64) -> Promise<Data>
//    func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool>
    func eth_signData(account: EthereumAddress, data: Data, networkId: UInt64) -> Promise<Data>
    //func eth_signTypedData(account: String) -> Promise<Array<UInt8>>
}
