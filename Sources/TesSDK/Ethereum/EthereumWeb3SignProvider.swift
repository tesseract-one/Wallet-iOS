//
//  EthereumWeb3SignProvider.swift
//  TesSDK
//
//  Created by Yehor Popovych on 3/2/19.
//  Copyright © 2019 Crossroad Labs s.r.o. All rights reserved.
//

import Foundation
import struct Web3.EthereumTransaction
import Web3

class EthereumSignWeb3Provider: Web3Provider {
    private let provider: Web3Provider
    private let web3: Web3
    
    public var account: Web3EthereumAddress? = nil
    public let networkId: UInt64
    public let chainId: UInt64
    public let sign: EthereumSignProvider
    
    init(rpcId: UInt64, chainId: UInt64, web3Provider: Web3Provider, signProvider: EthereumSignProvider) {
        provider = web3Provider
        sign = signProvider
        web3 = Web3(provider: web3Provider, rpcId: Int(rpcId))
        networkId = rpcId
        self.chainId = chainId
    }
    
    private func signTransaction(request: RPCRequest<[Web3EthereumTransaction]>) -> Promise<EthereumSignedTransaction> {
        return request.params[0]
            .autononce(web3: web3)
            .then { $0.autogas(web3: self.web3) }
            .then { tx -> Promise<(EthereumTransaction, Data)> in
                let tesTx = try tx.tesseract()
                return self.sign
                    .eth_signTx(tx: tesTx, networkId: self.networkId, chainId: self.chainId)
                    .map{ (tesTx, $0) }
            }
            .map { tx, sig in try EthereumSignedTransaction(tx: tx, signature: sig, chainId: BigUInt(self.chainId))}
    }
    
    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) {
        switch request.method {
        case "eth_accounts":
            sign
                .eth_accounts(networkId: networkId)
                .done { accounts in
                    response(Web3Response(status: .success(accounts.map { $0.web3 })) as! Web3Response<Result>)
                }
                .catch { response(Web3Response(error: $0)) }
        case "personal_sign":
            guard let account = account else {
                response(Web3Response(error: EthereumSignProviderError.emptyAccount))
                return
            }
            let req = request as! RPCRequest<[String]>
            sign
                .eth_signData(account: account.tesseract, data: Data(bytes: req.params[0].hexToBytes()), networkId: networkId)
                .map { $0.bytes.reduce("0x") {$0 + String(format: "%02x", $1)} }
                .done { response(Web3Response(status: .success($0)) as! Web3Response<Result>) }
                .catch { response(Web3Response(error: $0))}
        case "eth_sendTransaction":
            signTransaction(request: request as! RPCRequest<[Web3EthereumTransaction]>)
                .then { self.web3.eth.sendRawTransaction(transaction: $0) }
                .done { response(Web3Response(status: .success($0)) as! Web3Response<Result>) }
                .catch { response(Web3Response(error: $0)) }
        default:
            provider.send(request: request, response: response)
        }
    }
}

extension Web3 {
    public var activeAccount: Web3EthereumAddress? {
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
