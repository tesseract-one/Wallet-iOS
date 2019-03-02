//
//  EthereumAPIs.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import Web3

extension Network {
    public static let Ethereum = Network(nId: 0x8000003c)
}

public class EthereumAPIs: NetworkAPI {
    public private(set) var signProvider: EthereumSignProvider?
    
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
    
    public func web3(rpcUrl: String, chainId: Int) -> Web3 {
        let web3Provider = Web3HttpProvider(rpcURL: rpcUrl)
        let sign = EthereumSignWeb3Provider(rpcId: chainId, web3Provider: web3Provider, signProvider: signProvider!)
        return Web3(provider: sign, rpcId: chainId)
    }
    
    public func etherscan(apiUrl: String, apiToken: String) -> EthereumEtherscanAPI {
        return EthereumEtherscanAPI(apiUrl: apiUrl, apiToken: apiToken)
    }
}

extension dAPI {
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
