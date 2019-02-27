//
//  Ethereum.swift
//  TesSDK
//
//  Created by Yehor Popovych on 2/25/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Web3

enum EthereumSignProviderError: Error {
    case accountDoesNotExist(String)
}

public protocol EthereumSignProvider: SignProvider {
    func eth_accounts() -> Promise<Array<String>>
    func eth_signTx(account: String, tx: EthereumTransaction) -> Promise<EthereumSignedTransaction>
    func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool>
    func eth_signData(account: String, data: Data) -> Promise<String>
    //func eth_signTypedData(account: String) -> Promise<Array<UInt8>>
}

public class EthereumAPIs: NetworkAPI {
    private var signProvider: EthereumSignProvider?
    
    public var activeAccount: String? = nil
    
    init(_ sign: EthereumSignProvider?) {
        signProvider = sign
    }
    
    public func updateSignProvider(provider: SignProvider?) {
        if let p = provider as? EthereumSignProvider {
            signProvider = p
        } else {
            signProvider = nil
        }
    }
}

public extension Network {
    public static let Ethereum = Network(nId: 0x8000003c)
}

public extension dAPI {
    public var Ethereum: EthereumAPIs {
        get {
            if let network = networkAPIs[.Ethereum] {
                return network as! EthereumAPIs
            }
            var network: EthereumAPIs
            if let sProvider = signProvider as? EthereumSignProvider {
                network = EthereumAPIs(sProvider)
            } else {
                network = EthereumAPIs(nil)
            }
            networkAPIs[.Ethereum] = network
            return network
        }
    }
}
