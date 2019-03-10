//
//  EthereumWeb3SignProvider.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import Web3

class EthereumSignWeb3Provider: Web3Provider {
    private let provider: Web3Provider
    private let web3: Web3
    
    public var account: String? = nil
    public let chainId: EthereumQuantity
    public let sign: EthereumSignProvider
    
    init(rpcId: Int, web3Provider: Web3Provider, signProvider: EthereumSignProvider) {
        provider = web3Provider
        sign = signProvider
        web3 = Web3(provider: web3Provider, rpcId: rpcId)
        chainId = EthereumQuantity(quantity: BigUInt(rpcId))
    }
    
    private func signTransaction(request: RPCRequest<[EthereumTransaction]>) -> Promise<EthereumSignedTransaction> {
        return request.params[0]
            .autononce(web3: web3)
            .then { $0.autogas(web3: self.web3) }
            .then { self.sign.eth_signTx(tx: $0, chainId: self.chainId) }
    }
    
    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) {
        switch request.method {
        case "eth_accounts":
            sign
                .eth_accounts()
                .done { accounts in
                    let addresses = try accounts.map { try EthereumAddress(hex: $0, eip55: false) }
                    response(Web3Response(status: .success(addresses)) as! Web3Response<Result>)
                }
                .catch { response(Web3Response(error: $0)) }
        case "personal_sign":
            guard let account = account else {
                response(Web3Response(error: EthereumSignProviderError.emptyAccount))
                return
            }
            let req = request as! RPCRequest<[String]>
            sign
                .eth_signData(account: account, data: Data(bytes: req.params[0].hexToBytes()))
                .map { $0.bytes.reduce("0x") {$0 + String(format: "%02x", $1)} }
                .done { response(Web3Response(status: .success($0)) as! Web3Response<Result>) }
                .catch { response(Web3Response(error: $0))}
        case "eth_sendTransaction":
            signTransaction(request: request as! RPCRequest<[EthereumTransaction]>)
                .then { self.web3.eth.sendRawTransaction(transaction: $0) }
                .done { response(Web3Response(status: .success($0)) as! Web3Response<Result>) }
                .catch { response(Web3Response(error: $0)) }
        default:
            provider.send(request: request, response: response)
        }
    }
}

extension Web3 {
    public var activeAccount: String? {
        get {
            if let sign = properties.provider as? EthereumSignWeb3Provider {
                return sign.account
            }
            return nil
        }
        set {
            guard let sign = properties.provider as? EthereumSignWeb3Provider else { return }
            sign.account = newValue
        }
    }
}
