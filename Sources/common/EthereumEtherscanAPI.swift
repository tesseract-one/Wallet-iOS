//
//  EthereumEtherscanProvider.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import PromiseKit
import Wallet
import Ethereum

private struct ESResponse: Codable {
    let status: String
    let message: String
    let result: Array<EthereumTransactionLog>
}

public struct EthereumTransactionLog: Codable {
    public let blockNumber: String
    public let timeStamp: String
    public let hash: String
    public let nonce: String
    public let blockHash: String
    public let transactionIndex: String
    public let from: String
    public let to: String
    public let value: String
    public let gas: String
    public let gasPrice: String
    public let isError: String
    public let txreceipt_status: String
    public let input: String
    public let contractAddress: String
    public let cumulativeGasUsed: String
    public let gasUsed: String
    public let confirmations: String
}

public struct EthereumEtherscanAPI {
    public let apiUrl: String
    public let apiToken: String
    
    init(apiUrl: String, apiToken: String) {
        self.apiUrl = apiUrl
        self.apiToken = apiToken
    }
    
    public func getTransactions(address: String) -> Promise<Array<EthereumTransactionLog>> {
        let url = apiUrl + "/api?module=account&action=txlist&address=\(address)&startblock=0&endblock=99999999&sort=asc&apikey=\(apiToken)"
        return URLSession.shared.dataTask(.promise, with: URL(string: url)!)
            .validate()
            .map {
                try JSONDecoder().decode(ESResponse.self, from: $0.data) //.decode(Array<Any>.self, with: $0.data)
            }
            .map { $0.result }
    }
}

extension InstanceAPIRegistry {
    public func etherscan(apiUrl: String, apiToken: String) -> EthereumEtherscanAPI {
        return EthereumEtherscanAPI(apiUrl: apiUrl, apiToken: apiToken)
    }
}

