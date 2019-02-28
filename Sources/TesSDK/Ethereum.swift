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

public enum EthereumSignProviderError: Error {
    case accountDoesNotExist(String)
    case emptyAccount
    case mandatoryFieldMissing(String)
    case emptyResponse(String)
}

public protocol EthereumSignProvider: SignProvider {
    func eth_accounts() -> Promise<Array<String>>
    func eth_signTx(account: String, tx: EthereumTransaction, chainId: EthereumQuantity) -> Promise<EthereumSignedTransaction>
    func eth_verify(account: String, data: Data, signature: Data) -> Promise<Bool>
    func eth_signData(account: String, data: Data) -> Promise<String>
    //func eth_signTypedData(account: String) -> Promise<Array<UInt8>>
}

class EthereumSignWeb3Provider: Web3Provider {
    private let provider: Web3Provider
    private let sign: EthereumSignProvider
    private let chainId: EthereumQuantity
    
    private let web3: Web3
    
    public var account: String? = nil
    
    init(rpcId: Int, web3Provider: Web3Provider, signProvider: EthereumSignProvider) {
        provider = web3Provider
        sign = signProvider
        web3 = Web3(provider: web3Provider, rpcId: rpcId)
        chainId = EthereumQuantity(quantity: BigUInt(rpcId))
    }
    
    private func signTransaction(account: String, request: RPCRequest<[EthereumTransaction]>) -> Promise<EthereumSignedTransaction> {
        return request.params[0]
            .autononce(web3: web3)
            .then { $0.autogas(web3: self.web3) }
            .then { self.sign.eth_signTx(account: account, tx: $0, chainId: self.chainId) }
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
            guard let account = account else {
                response(Web3Response(error: EthereumSignProviderError.emptyAccount))
                return
            }
            signTransaction(account: account, request: request as! RPCRequest<[EthereumTransaction]>)
                .then { self.web3.eth.sendRawTransaction(transaction: $0) }
                .done { response(Web3Response(status: .success($0)) as! Web3Response<Result>) }
                .catch { response(Web3Response(error: $0)) }
        default:
            provider.send(request: request, response: response)
        }
    }
}

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


public class EthereumAPIs: NetworkAPI {
    private var signProvider: EthereumSignProvider?
    
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
