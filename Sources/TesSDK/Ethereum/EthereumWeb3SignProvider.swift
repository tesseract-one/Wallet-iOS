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
    enum Result<T> {
        case value(T)
        case error(Swift.Error)
    }
    
    private let _provider: Web3Provider
    fileprivate let _web3: Web3
    private var _networkId: UInt64?
    private var _chainId: UInt64?
    
    public let sign: EthereumSignProvider
    
    init(chainId: UInt64?, web3Provider: Web3Provider, signProvider: EthereumSignProvider) {
        _provider = web3Provider
        sign = signProvider
        _web3 = Web3(provider: web3Provider)
        _networkId = nil
        _chainId = chainId
        networkId({ _ in }) // Prefetch network and chain id
    }
    
    public func chainId(_ cb: @escaping (Result<UInt64>) -> Void) {
        if let chainId = _chainId {
            cb(.value(chainId))
            return
        }
        networkId(cb)
    }
    
    public func networkId(_ cb: @escaping (Result<UInt64>) -> Void) {
        if let networkId = _networkId {
            cb(.value(networkId))
            return
        }
        _web3.net.version() { result in
            switch result.status {
            case .success(let ver):
                guard let id = UInt64(ver, radix: 10) else {
                    cb(.error(EthereumSignProviderError.nonIntNetworkVersion(ver)))
                    return
                }
                self._networkId = id
                self._chainId = self._chainId ?? id
                cb(.value(id))
            case .failure(let err): cb(.error(err))
            }
        }
    }
    
    public func networkAndChainId(_ cb: @escaping (Result<(nId: UInt64, cId: UInt64)>) -> Void) {
        networkId { res in
            switch res {
            case .error(let err): cb(.error(err))
            case .value(let nId):
                self.chainId { res in
                    switch res {
                    case .error(let err): cb(.error(err))
                    case .value(let cId): cb(.value((nId: nId, cId: cId)))
                    }
                }
            }
        }
    }
    
    func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) {
        switch request.method {
        case "eth_accounts":
            eth_accounts { response($0 as! Web3Response<Result>) }
        case "personal_sign":
            personal_sign(req: request as! RPCRequest<EthereumValue>) { response($0 as! Web3Response<Result>) }
        case "eth_sign":
            eth_sign(req: request as! RPCRequest<EthereumValue>) { response($0 as! Web3Response<Result>) }
        case "eth_sendTransaction":
            eth_sendTransaction(request: request as! RPCRequest<[Web3EthereumTransaction]>) {
                response($0 as! Web3Response<Result>)
            }
        default:
            _provider.send(request: request, response: response)
        }
    }
}

// eth_accounts
extension EthereumSignWeb3Provider {
    fileprivate func eth_accounts(response: @escaping Web3ResponseCompletion<[Web3EthereumAddress]>) {
        networkId { res in
            switch res {
            case .error(let err): response(Web3Response(status: .failure(err)))
            case .value(let networkId):
                self.sign.eth_accounts(networkId: networkId)
                    .done { accounts in
                        response(Web3Response(status: .success(accounts.map { $0.web3 })))
                    }
                    .catch { response(Web3Response(error: $0)) }
            }
        }
    }
}

// personal_sign, eth_sign
extension EthereumSignWeb3Provider {
    private func sign_data(account: Web3EthereumAddress, data: EthereumData, cb: @escaping Web3ResponseCompletion<EthereumData>) {
        networkId { res in
            switch res {
            case .error(let err): cb(Web3Response(error: err))
            case .value(let networkId):
                self.sign.eth_signData(account: account.tesseract, data: Data(bytes: data.bytes), networkId: networkId)
                    .done { signature in
                        cb(Web3Response(status: .success(EthereumData(raw: signature.bytes))))
                    }
                    .catch { cb(Web3Response(error: $0)) }
            }
        }
        
    }
    
    fileprivate func personal_sign(req: RPCRequest<EthereumValue>, response: @escaping Web3ResponseCompletion<EthereumData>) {
        guard let params = req.params.array else {
            response(Web3Response(error: EthereumSignProviderError.mandatoryFieldMissing("array")))
            return
        }
        guard params.count > 1 else {
            response(Web3Response(error: EthereumSignProviderError.emptyAccount))
            return
        }
        let account: Web3EthereumAddress
        do {
            account = try Web3EthereumAddress(ethereumValue: params[1])
        } catch(let err) {
            response(Web3Response(error: err))
            return
        }
        let data: EthereumData
        do {
            data = try EthereumData(ethereumValue: params[0])
        } catch(let err) {
            response(Web3Response(error: err))
            return
        }
        sign_data(account: account, data: data, cb: response)
    }
    
    fileprivate func eth_sign(req: RPCRequest<EthereumValue>, response: @escaping Web3ResponseCompletion<EthereumData>) {
        guard let params = req.params.array else {
            response(Web3Response(error: EthereumSignProviderError.mandatoryFieldMissing("array")))
            return
        }
        let account: Web3EthereumAddress
        do {
            account = try Web3EthereumAddress(ethereumValue: params[0])
        } catch(let err) {
            response(Web3Response(error: err))
            return
        }
        let data: EthereumData
        do {
            data = try EthereumData(ethereumValue: params[1])
        } catch(let err) {
            response(Web3Response(error: err))
            return
        }
        sign_data(account: account, data: data, cb: response)
    }
}


// eth_sendTransaction
extension EthereumSignWeb3Provider {
    public func autoNonce(_ tx: Web3EthereumTransaction, cb: @escaping (Result<Web3EthereumTransaction>) -> Void) {
        guard let from = tx.from else {
            cb(.error(EthereumSignProviderError.mandatoryFieldMissing("from")))
            return
        }
        
        guard tx.nonce == nil else {
            cb(.value(tx))
            return
        }
        
        _web3.eth.getTransactionCount(address: from, block: .pending) { res in
            if let val = res.result {
                var mTx = tx
                mTx.nonce = val
                cb(.value(mTx))
            } else {
                cb(.error(res.error!))
            }
        }
    }
    
    public func autoGas(_ tx: Web3EthereumTransaction, cb: @escaping (Result<Web3EthereumTransaction>) -> Void) {
        if tx.gas != nil && tx.gasPrice != nil {
            cb(.value(tx))
            return
        }
        let gas = { (res: Web3Response<EthereumQuantity>) -> Void in
            guard res.error == nil else {
                cb(.error(res.error!))
                return
            }
            var mTx = tx
            mTx.gas = res.result
            guard mTx.gasPrice == nil else {
                cb(.value(mTx))
                return
            }
            self._web3.eth.gasPrice { res in
                guard res.error == nil else {
                    cb(.error(res.error!))
                    return
                }
                var mTx2 = mTx
                mTx2.gasPrice = res.result!
                cb(.value(mTx2))
            }
        }
        if let txG = tx.gas {
            gas(Web3Response(status: .success(txG)))
        } else {
            guard let to = tx.to else {
                cb(.error(EthereumSignProviderError.mandatoryFieldMissing("to")))
                return
            }
            _web3.eth.estimateGas(
                call: EthereumCall(from: tx.from, to: to, gas: tx.gas, gasPrice: tx.gasPrice, value: tx.value, data: tx.data),
                response: gas
            )
        }
    }
    
    fileprivate func eth_sendTransaction(request: RPCRequest<[Web3EthereumTransaction]>, cb: @escaping (Web3Response<EthereumData>) -> Void) {
        signTransaction(request: request) { res in
            switch res {
            case .error(let err): cb(Web3Response(status: .failure(err)))
            case .value(let tx): self._web3.eth.sendRawTransaction(transaction: tx, response: cb)
            }
        }
    }
    
    fileprivate func signTransaction(request: RPCRequest<[Web3EthereumTransaction]>, cb: @escaping (Result<EthereumSignedTransaction>) -> Void) {
        let signTx = { (web3Tx: Web3EthereumTransaction, nId: UInt64, cId: UInt64) -> Void in
            let tx: EthereumTransaction
            do {
                tx = try web3Tx.tesseract()
            } catch(let err) {
                cb(.error(err))
                return
            }
            self.sign.eth_signTx(tx: tx, networkId: nId, chainId: cId)
                .done { sig in
                    try cb(.value(EthereumSignedTransaction(tx: tx, signature: sig, chainId: BigUInt(cId))))
                }
                .catch { cb(.error($0)) }
        }
        
        let ids = { (web3Tx: Web3EthereumTransaction) -> Void in
            self.networkAndChainId { res in
                switch res {
                case .error(let err): cb(.error(err))
                case .value(let val): signTx(web3Tx, val.nId, val.cId)
                }
            }
        }
        
        autoNonce(request.params[0]) { result in
            switch result {
            case .error(let err): cb(.error(err))
            case .value(let nTx):
                self.autoGas(nTx) { result in
                    switch result {
                    case .error(let err): cb(.error(err))
                    case .value(let gTx): ids(gTx)
                    }
                }
            }
        }
    }
}
